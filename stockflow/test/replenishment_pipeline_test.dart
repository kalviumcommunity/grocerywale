import 'package:flutter_test/flutter_test.dart';
import 'package:stockflow/models/grocery_item.dart';
import 'package:stockflow/models/replenishment_request.dart';
import 'package:stockflow/models/store_info.dart';
import 'package:stockflow/services/inventory_service.dart';

void main() {
  group('Replenishment Pipeline & Fast-Moving Stock Tests', () {
    late InventoryService service;

    setUp(() {
      service = InventoryService();
    });

    test('Identifies fast-moving items at risk of running out', () {
      final atRisk = service.fastMovingItemsAtRisk;
      expect(atRisk, isNotEmpty);
      expect(atRisk.every((i) => i.velocity == ItemVelocity.fastMoving), isTrue);

      // Verify burn rate and stockout calculation
      final topItem = atRisk.first;
      expect(topItem.hoursUntilStockout, isNonNegative);
      expect(topItem.isCriticalRisk || topItem.isLowStock, isTrue);
    });

    test('Creates urgent replenishment request for fast-moving items', () {
      final milk = service.catalog.firstWhere((i) => i.id == 'item_milk_1l');
      final initialRequestsCount = service.requests.length;

      service.quickRestockFastMovingItem(milk, quantity: 20);

      expect(service.requests.length, initialRequestsCount + 1);
      final newReq = service.requests.first;
      expect(newReq.priority, ReplenishmentPriority.urgentFastMoving);
      expect(newReq.status, ReplenishmentStatus.requested);
      expect(newReq.items.first.itemId, 'item_milk_1l');
      expect(newReq.containsFastMoving, isTrue);
    });

    test('Full replenishment cycle: Requested -> Approved -> Dispatched -> Received', () {
      final milk = service.catalog.firstWhere((i) => i.id == 'item_milk_1l');
      final initialStoreStock = milk.storeStock;
      final initialWarehouseStock = milk.warehouseStock;

      // 1. Create request
      final request = service.createRequest(
        items: [ReplenishmentItem.fromGroceryItem(milk, 15)],
        priority: ReplenishmentPriority.urgentFastMoving,
        notes: 'End-to-end replenishment cycle verification',
      );

      expect(request.status, ReplenishmentStatus.requested);

      // 2. Central warehouse approves and reserves stock
      final approved = service.approveRequest(
        request.id,
        approvedBy: 'Central Warehouse Test Lead',
      );
      expect(approved, isTrue);

      final approvedReq = service.getRequestById(request.id)!;
      expect(approvedReq.status, ReplenishmentStatus.approved);
      expect(approvedReq.approvedAt, isNotNull);

      // Verify warehouse stock deducted
      final catalogMilkAfterApproval = service.catalog.firstWhere((i) => i.id == 'item_milk_1l');
      expect(catalogMilkAfterApproval.warehouseStock, initialWarehouseStock - 15);

      // 3. Central warehouse dispatches order
      final dispatched = service.dispatchRequest(
        request.id,
        trackingReference: 'TRK-TEST-999',
        carrierName: 'ColdChain Reefer Unit #5',
        estimatedDeliveryAt: DateTime.now().add(const Duration(hours: 1)),
      );
      expect(dispatched, isTrue);

      final dispatchedReq = service.getRequestById(request.id)!;
      expect(dispatchedReq.status, ReplenishmentStatus.dispatched);
      expect(dispatchedReq.trackingReference, 'TRK-TEST-999');

      // 4. Store manager confirms delivery
      final received = service.markReceived(
        request.id,
        receivedBy: 'Store Manager Sarah Jenkins',
      );
      expect(received, isTrue);

      final receivedReq = service.getRequestById(request.id)!;
      expect(receivedReq.status, ReplenishmentStatus.received);
      expect(receivedReq.receivedAt, isNotNull);

      // Verify store stock incremented
      final catalogMilkAfterReceipt = service.catalog.firstWhere((i) => i.id == 'item_milk_1l');
      expect(catalogMilkAfterReceipt.storeStock, initialStoreStock + 15);
    });

    test('Role switching and filtered request visibility', () {
      service.setRole(UserRole.storeManager);
      final storeRequests = service.getRequestsForRole();
      expect(storeRequests.every((r) => r.storeId == service.currentStore.id), isTrue);

      service.setRole(UserRole.warehouseManager);
      final warehouseRequests = service.getRequestsForRole();
      // Warehouse manager sees requests across multiple stores
      final storeIds = warehouseRequests.map((r) => r.storeId).toSet();
      expect(storeIds.length, greaterThanOrEqualTo(1));
    });
  });
}
