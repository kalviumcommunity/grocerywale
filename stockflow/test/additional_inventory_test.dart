import 'package:stockflow/screens/create_request_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stockflow/models/grocery_item.dart';
import 'package:stockflow/models/replenishment_request.dart';
import 'package:stockflow/models/store_info.dart';
import 'package:stockflow/services/inventory_service.dart';

void main() {
  late InventoryService service;

  setUp(() {
    service = InventoryService();
    service.resetDemoData();
  });

  ReplenishmentRequest createTestRequest({
    int quantity = 5,
    StoreInfo? store,
  }) {
    final milk = service.catalog.firstWhere(
      (item) => item.id == 'item_milk_1l',
    );

    return service.createRequest(
      items: [
        ReplenishmentItem.fromGroceryItem(milk, quantity),
      ],
      priority: ReplenishmentPriority.standard,
      forStore: store,
    );
  }

  // EXISTING TESTS: 16-18

  test('Test 16: Detect low stock products', () {
    final milk = service.catalog.firstWhere(
      (item) => item.id == 'item_milk_1l',
    );

    expect(milk.isLowStock, true);
    expect(milk.isCriticalRisk, true);
  });

  test('Test 17: Create a replenishment request', () {
    final milk = service.catalog.firstWhere(
      (item) => item.id == 'item_milk_1l',
    );

    final request = service.createRequest(
      items: [
        ReplenishmentItem.fromGroceryItem(milk, 10),
      ],
      priority: ReplenishmentPriority.urgentFastMoving,
      notes: 'Automated test request',
    );

    expect(request.status, ReplenishmentStatus.requested);
    expect(request.totalRequestedUnits, 10);
    expect(service.getRequestById(request.id), isNotNull);
  });

  test('Test 18: Approve replenishment request', () {
    final milk = service.catalog.firstWhere(
      (item) => item.id == 'item_milk_1l',
    );

    final initialWarehouseStock = milk.warehouseStock;

    final request = service.createRequest(
      items: [
        ReplenishmentItem.fromGroceryItem(milk, 5),
      ],
      priority: ReplenishmentPriority.standard,
    );

    final result = service.approveRequest(
      request.id,
      approvedBy: 'Test Supervisor',
    );

    expect(result, true);

    final updatedRequest = service.getRequestById(request.id);

    expect(updatedRequest!.status, ReplenishmentStatus.approved);
    expect(updatedRequest.items.first.approvedQuantity, 5);

    final updatedMilk = service.catalog.firstWhere(
      (item) => item.id == 'item_milk_1l',
    );

    expect(
      updatedMilk.warehouseStock,
      initialWarehouseStock - 5,
    );
  });

  // NEW TESTS: 19-28

  test('Test 19: Identify fast-moving products at risk', () {
    final items = service.fastMovingItemsAtRisk;

    expect(items, isNotEmpty);
    expect(
      items.every((item) =>
          item.velocity == ItemVelocity.fastMoving),
      true,
    );
  });

  test('Test 20: Identify critical stock products', () {
    final items = service.criticalItems;

    expect(items, isNotEmpty);
    expect(items.every((item) => item.isCriticalRisk), true);
  });

  test('Test 21: Switch to warehouse manager role', () {
    service.setRole(UserRole.warehouseManager);

    expect(service.currentRole, UserRole.warehouseManager);
    expect(
      service.currentRoleTitle,
      'Central Warehouse Supervisor',
    );
  });

  test('Test 22: Update stockout alert preference', () {
    service.toggleStockoutAlerts(false);

    expect(service.stockoutAlertsEnabled, false);

    service.toggleStockoutAlerts(true);

    expect(service.stockoutAlertsEnabled, true);
  });

  test('Test 23: Create request for another store', () {
    final secondStore = service.stores[1];

    final request = createTestRequest(store: secondStore);

    expect(request.storeId, secondStore.id);
    expect(request.storeName, secondStore.name);
  });

  test('Test 24: Reject approval of an already approved request', () {
    final request = createTestRequest();

    expect(service.approveRequest(request.id), true);
    expect(service.approveRequest(request.id), false);

    expect(
      service.getRequestById(request.id)!.status,
      ReplenishmentStatus.approved,
    );
  });

  test('Test 25: Dispatch an approved request', () {
    final request = createTestRequest();

    expect(service.approveRequest(request.id), true);

    final result = service.dispatchRequest(
      request.id,
      trackingReference: 'TRACK-025',
      carrierName: 'Test Carrier',
    );

    expect(result, true);

    final updated = service.getRequestById(request.id)!;

    expect(updated.status, ReplenishmentStatus.dispatched);
    expect(updated.trackingReference, 'TRACK-025');
    expect(updated.carrierName, 'Test Carrier');
  });

  test('Test 26: Receive dispatched stock and update inventory', () {
    final milk = service.catalog.firstWhere(
      (item) => item.id == 'item_milk_1l',
    );

    final initialStock = milk.storeStock;
    final request = createTestRequest(quantity: 5);

    expect(service.approveRequest(request.id), true);

    expect(
      service.dispatchRequest(
        request.id,
        trackingReference: 'TRACK-026',
        carrierName: 'Test Carrier',
      ),
      true,
    );

    expect(
      service.markReceived(
        request.id,
        receivedBy: 'Test Manager',
      ),
      true,
    );

    final updatedMilk = service.catalog.firstWhere(
      (item) => item.id == 'item_milk_1l',
    );

    expect(updatedMilk.storeStock, initialStock + 5);

    expect(
      service.getRequestById(request.id)!.status,
      ReplenishmentStatus.received,
    );
  });

  test('Test 27: Cancel a requested replenishment order', () {
    final request = createTestRequest();

    final result = service.cancelRequest(
      request.id,
      reason: 'Testing cancellation',
    );

    expect(result, true);

    final updated = service.getRequestById(request.id)!;

    expect(updated.status, ReplenishmentStatus.cancelled);
    expect(updated.notes, contains('Testing cancellation'));
  });

  group('Create Request Screen Widget Tests', () {
  final service = InventoryService();

  setUp(() {
    service.resetDemoData();
    service.setRole(UserRole.storeManager);
  });

  testWidgets('Test 29: Render Create Request screen', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: CreateRequestScreen(),
      ),
    );

    expect(find.text('New Replenishment Request'), findsOneWidget);
    expect(find.text('Replenishment Urgency'), findsOneWidget);
    expect(find.text('Emergency Restock (Fast-Moving Item)'), findsOneWidget);
    expect(find.text('Standard Replenishment Cycle'), findsOneWidget);
    expect(find.text('Submit Request'), findsOneWidget);
  });

  testWidgets('Test 30: Search products by name', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: CreateRequestScreen(),
      ),
    );

    expect(find.text('Whole Fresh Milk 1L'), findsOneWidget);

    await tester.enterText(
      find.byType(TextField).first,
      'Basmati',
    );
    await tester.pumpAndSettle();

    expect(find.text('Premium Basmati Rice 5kg'), findsOneWidget);
    expect(find.text('Whole Fresh Milk 1L'), findsNothing);
  });

  testWidgets('Test 31: Select quantity and update selected units',
      (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: CreateRequestScreen(),
      ),
    );

    expect(find.text('0 items selected'), findsOneWidget);

    await tester.tap(find.byIcon(Icons.add_circle_outline).first);
    await tester.pumpAndSettle();

    expect(find.text('5 items selected'), findsOneWidget);
  });
});

  group('StoreInfo Model Tests', () {
    test('Test 29: Create StoreInfo object', () {
      const store = StoreInfo(
        id: 'S001',
        name: 'Jaipur Store',
        code: 'JPR01',
        location: 'Jaipur',
        managerName: 'Rahul',
        contactPhone: '9876543210',
      );

      expect(store.id, 'S001');
      expect(store.name, 'Jaipur Store');
      expect(store.code, 'JPR01');
      expect(store.location, 'Jaipur');
      expect(store.managerName, 'Rahul');
      expect(store.contactPhone, '9876543210');
    });

    test('Test 30: Convert StoreInfo to Map', () {
      const store = StoreInfo(
        id: 'S001',
        name: 'Jaipur Store',
        code: 'JPR01',
        location: 'Jaipur',
        managerName: 'Rahul',
        contactPhone: '9876543210',
      );

      final map = store.toMap();

      expect(map['id'], 'S001');
      expect(map['name'], 'Jaipur Store');
      expect(map['code'], 'JPR01');
      expect(map['location'], 'Jaipur');
      expect(map['managerName'], 'Rahul');
      expect(map['contactPhone'], '9876543210');
    });

    test('Test 31: Create StoreInfo from Map', () {
      final store = StoreInfo.fromMap({
        'id': 'S002',
        'name': 'Delhi Store',
        'code': 'DEL01',
        'location': 'Delhi',
        'managerName': 'Amit',
        'contactPhone': '9876500000',
      });

      expect(store.id, 'S002');
      expect(store.name, 'Delhi Store');
      expect(store.code, 'DEL01');
      expect(store.location, 'Delhi');
      expect(store.managerName, 'Amit');
      expect(store.contactPhone, '9876500000');
    });

    test('Test 32: Handle missing fields in Map', () {
      final store = StoreInfo.fromMap({});

      expect(store.id, '');
      expect(store.name, '');
      expect(store.code, '');
      expect(store.location, '');
      expect(store.managerName, '');
      expect(store.contactPhone, '');
    });

    test('Test 33: Check UserRole enum values', () {
      expect(UserRole.values.length, 2);
      expect(UserRole.values, contains(UserRole.storeManager));
      expect(UserRole.values, contains(UserRole.warehouseManager));
    });
  });


  group('Replenishment Model Tests', () {
    final createdAt = DateTime(2026, 11, 3, 10, 0);
    final updatedAt = DateTime(2026, 11, 3, 11, 0);

    final item = ReplenishmentItem(
      itemId: 'I001',
      itemName: 'Milk',
      sku: 'MILK01',
      unit: 'litre',
      isFastMoving: true,
      requestedQuantity: 10,
      approvedQuantity: 8,
      receivedQuantity: 5,
      unitPrice: 50.0,
    );

    test('Test 34: Check all status display names and step indexes', () {
      expect(ReplenishmentStatus.requested.displayName, 'Requested');
      expect(ReplenishmentStatus.approved.displayName, 'Approved');
      expect(ReplenishmentStatus.dispatched.displayName, 'Dispatched');
      expect(ReplenishmentStatus.received.displayName, 'Received');
      expect(ReplenishmentStatus.cancelled.displayName, 'Cancelled');

      expect(ReplenishmentStatus.requested.stepIndex, 0);
      expect(ReplenishmentStatus.approved.stepIndex, 1);
      expect(ReplenishmentStatus.dispatched.stepIndex, 2);
      expect(ReplenishmentStatus.received.stepIndex, 3);
      expect(ReplenishmentStatus.cancelled.stepIndex, -1);
    });

    test('Test 35: Check priority display names and urgency', () {
      expect(
        ReplenishmentPriority.urgentFastMoving.displayName,
        '⚡ Urgent (Fast-Moving Stockout)',
      );
      expect(
        ReplenishmentPriority.high.displayName,
        'High Priority',
      );
      expect(
        ReplenishmentPriority.standard.displayName,
        'Standard Cycle',
      );

      expect(ReplenishmentPriority.urgentFastMoving.isUrgent, true);
      expect(ReplenishmentPriority.high.isUrgent, true);
      expect(ReplenishmentPriority.standard.isUrgent, false);
    });

    test('Test 36: Convert ReplenishmentItem to Map and back', () {
      final map = item.toMap();
      final result = ReplenishmentItem.fromMap(map);

      expect(result.itemId, item.itemId);
      expect(result.itemName, item.itemName);
      expect(result.sku, item.sku);
      expect(result.unit, item.unit);
      expect(result.isFastMoving, item.isFastMoving);
      expect(result.requestedQuantity, 10);
      expect(result.approvedQuantity, 8);
      expect(result.receivedQuantity, 5);
      expect(result.unitPrice, 50.0);
    });

    test('Test 37: Handle missing ReplenishmentItem Map fields', () {
      final result = ReplenishmentItem.fromMap({});

      expect(result.itemId, '');
      expect(result.itemName, '');
      expect(result.sku, '');
      expect(result.unit, 'units');
      expect(result.isFastMoving, false);
      expect(result.requestedQuantity, 0);
      expect(result.approvedQuantity, 0);
      expect(result.receivedQuantity, 0);
      expect(result.unitPrice, 0.0);
    });

    test('Test 38: ReplenishmentItem copyWith updates fields', () {
      final updated = item.copyWith(
        itemName: 'Updated Milk',
        requestedQuantity: 20,
        approvedQuantity: 15,
        unitPrice: 60.0,
      );

      expect(updated.itemName, 'Updated Milk');
      expect(updated.requestedQuantity, 20);
      expect(updated.approvedQuantity, 15);
      expect(updated.unitPrice, 60.0);
      expect(updated.itemId, item.itemId);
    });

    test('Test 39: Calculate request totals and fast-moving status', () {
      final request = ReplenishmentRequest(
        id: 'R001',
        storeId: 'S001',
        storeName: 'Jaipur Store',
        status: ReplenishmentStatus.requested,
        priority: ReplenishmentPriority.high,
        items: [
          item,
          ReplenishmentItem(
            itemId: 'I002',
            itemName: 'Rice',
            sku: 'RICE01',
            unit: 'kg',
            isFastMoving: false,
            requestedQuantity: 5,
            approvedQuantity: 4,
            unitPrice: 40.0,
          ),
        ],
        createdAt: createdAt,
        updatedAt: updatedAt,
      );

      expect(request.containsFastMoving, true);
      expect(request.totalRequestedUnits, 15);
      expect(request.totalApprovedUnits, 12);
      expect(request.estimatedTotalValue, 700.0);
    });

    test('Test 40: Empty request calculations', () {
      final request = ReplenishmentRequest(
        id: 'R002',
        storeId: 'S001',
        storeName: 'Jaipur Store',
        status: ReplenishmentStatus.requested,
        priority: ReplenishmentPriority.standard,
        items: [],
        createdAt: createdAt,
        updatedAt: updatedAt,
      );

      expect(request.containsFastMoving, false);
      expect(request.totalRequestedUnits, 0);
      expect(request.totalApprovedUnits, 0);
      expect(request.estimatedTotalValue, 0.0);
    });

    test('Test 41: ReplenishmentRequest Map round trip', () {
      final request = ReplenishmentRequest(
        id: 'R003',
        storeId: 'S001',
        storeName: 'Jaipur Store',
        status: ReplenishmentStatus.dispatched,
        priority: ReplenishmentPriority.urgentFastMoving,
        items: [item],
        createdAt: createdAt,
        updatedAt: updatedAt,
        approvedAt: createdAt,
        approvedBy: 'Manager',
        dispatchedAt: updatedAt,
        trackingReference: 'TRACK123',
        carrierName: 'Fast Delivery',
        estimatedDeliveryAt: updatedAt,
        receivedAt: updatedAt,
        receivedBy: 'Store Staff',
        notes: 'Test order',
      );

      final map = request.toMap();
      final result = ReplenishmentRequest.fromMap(map);

      expect(result.id, 'R003');
      expect(result.storeId, 'S001');
      expect(result.storeName, 'Jaipur Store');
      expect(result.status, ReplenishmentStatus.dispatched);
      expect(result.priority, ReplenishmentPriority.urgentFastMoving);
      expect(result.items.length, 1);
      expect(result.createdAt, createdAt);
      expect(result.updatedAt, updatedAt);
      expect(result.approvedAt, createdAt);
      expect(result.approvedBy, 'Manager');
      expect(result.dispatchedAt, updatedAt);
      expect(result.trackingReference, 'TRACK123');
      expect(result.carrierName, 'Fast Delivery');
      expect(result.estimatedDeliveryAt, updatedAt);
      expect(result.receivedAt, updatedAt);
      expect(result.receivedBy, 'Store Staff');
      expect(result.notes, 'Test order');
    });

    test('Test 42: Handle invalid and missing request Map values', () {
      final result = ReplenishmentRequest.fromMap({
        'status': 'invalid_status',
        'priority': 'invalid_priority',
        'createdAt': 'invalid_date',
        'updatedAt': 'invalid_date',
      });

      expect(result.id, '');
      expect(result.storeId, '');
      expect(result.storeName, '');
      expect(result.status, ReplenishmentStatus.requested);
      expect(result.priority, ReplenishmentPriority.standard);
      expect(result.items, isEmpty);
      expect(result.createdAt, isA<DateTime>());
      expect(result.updatedAt, isA<DateTime>());
      expect(result.approvedAt, isNull);
      expect(result.dispatchedAt, isNull);
      expect(result.receivedAt, isNull);
    });

    test('Test 43: ReplenishmentRequest copyWith updates fields', () {
      final request = ReplenishmentRequest(
        id: 'R004',
        storeId: 'S001',
        storeName: 'Jaipur Store',
        status: ReplenishmentStatus.requested,
        priority: ReplenishmentPriority.standard,
        items: [item],
        createdAt: createdAt,
        updatedAt: updatedAt,
      );

      final updated = request.copyWith(
        status: ReplenishmentStatus.approved,
        priority: ReplenishmentPriority.high,
        approvedBy: 'Warehouse Manager',
        notes: 'Approved successfully',
      );

      expect(updated.status, ReplenishmentStatus.approved);
      expect(updated.priority, ReplenishmentPriority.high);
      expect(updated.approvedBy, 'Warehouse Manager');
      expect(updated.notes, 'Approved successfully');
      expect(updated.id, request.id);
      expect(updated.items, request.items);
    });
  });


group('GroceryItem Model Tests', () {
  const item = GroceryItem(
    id: 'G001',
    name: 'Milk',
    sku: 'MILK01',
    category: ItemCategory.dairy,
    velocity: ItemVelocity.fastMoving,
    unit: 'litre',
    unitPrice: 50.0,
    storeStock: 20,
    warehouseStock: 100,
    reorderThreshold: 10,
    dailyBurnRate: 24,
    notes: 'Keep refrigerated',
  );

  test('Test 44: Check ItemVelocity display names', () {
    expect(ItemVelocity.fastMoving.displayName, 'Fast Moving');
    expect(ItemVelocity.mediumMoving.displayName, 'Standard');
    expect(ItemVelocity.slowMoving.displayName, 'Slow Moving');

    expect(ItemVelocity.fastMoving.isFastMoving, true);
    expect(ItemVelocity.mediumMoving.isFastMoving, false);
    expect(ItemVelocity.slowMoving.isFastMoving, false);
  });

  test('Test 45: Check ItemCategory display names', () {
    expect(ItemCategory.dairy.displayName, 'Dairy & Eggs');
    expect(ItemCategory.bakery.displayName, 'Bakery');
    expect(ItemCategory.produce.displayName, 'Fresh Produce');
    expect(ItemCategory.staples.displayName, 'Staples & Grains');
    expect(ItemCategory.beverages.displayName, 'Beverages');
    expect(ItemCategory.packagedGoods.displayName, 'Packaged Goods');
  });

  test('Test 46: Check low stock condition', () {
    expect(item.isLowStock, false);

    final lowStock = item.copyWith(storeStock: 10);
    expect(lowStock.isLowStock, true);
  });

  test('Test 47: Check critical risk when stock is zero', () {
    final result = item.copyWith(storeStock: 0);
    expect(result.isCriticalRisk, true);
    expect(result.hoursUntilStockout, 0.0);
  });

  test('Test 48: Check critical risk for fast moving low stock', () {
    final result = item.copyWith(
      storeStock: 5,
      reorderThreshold: 10,
      dailyBurnRate: 12,
    );

    expect(result.isCriticalRisk, true);
  });

  test('Test 49: Check hours until stockout', () {
    expect(item.hoursUntilStockout, 20.0);

    final noBurn = item.copyWith(dailyBurnRate: 0);
    expect(noBurn.hoursUntilStockout, 999.0);
  });

  test('Test 50: Check non-critical stock risk', () {
    final result = item.copyWith(
      storeStock: 100,
      reorderThreshold: 10,
      dailyBurnRate: 10,
      velocity: ItemVelocity.slowMoving,
    );

    expect(result.isCriticalRisk, false);
  });

  test('Test 51: Convert GroceryItem to Map and back', () {
    final map = item.toMap();
    final result = GroceryItem.fromMap(map);

    expect(result.id, item.id);
    expect(result.name, item.name);
    expect(result.sku, item.sku);
    expect(result.category, item.category);
    expect(result.velocity, item.velocity);
    expect(result.unit, item.unit);
    expect(result.unitPrice, item.unitPrice);
    expect(result.storeStock, item.storeStock);
    expect(result.warehouseStock, item.warehouseStock);
    expect(result.reorderThreshold, item.reorderThreshold);
    expect(result.dailyBurnRate, item.dailyBurnRate);
    expect(result.notes, item.notes);
  });

  test('Test 52: Handle missing and invalid Map values', () {
    final result = GroceryItem.fromMap({
      'category': 'invalid',
      'velocity': 'invalid',
    });

    expect(result.id, '');
    expect(result.name, '');
    expect(result.sku, '');
    expect(result.category, ItemCategory.packagedGoods);
    expect(result.velocity, ItemVelocity.mediumMoving);
    expect(result.unit, 'units');
    expect(result.unitPrice, 0.0);
    expect(result.storeStock, 0);
    expect(result.warehouseStock, 0);
    expect(result.reorderThreshold, 0);
    expect(result.dailyBurnRate, 0.0);
    expect(result.notes, isNull);
  });

  test('Test 53: GroceryItem copyWith updates fields', () {
    final updated = item.copyWith(
      name: 'Updated Milk',
      storeStock: 50,
      warehouseStock: 200,
      unitPrice: 60,
      notes: 'Updated notes',
    );

    expect(updated.name, 'Updated Milk');
    expect(updated.storeStock, 50);
    expect(updated.warehouseStock, 200);
    expect(updated.unitPrice, 60);
    expect(updated.notes, 'Updated notes');
    expect(updated.id, item.id);
  });
});


  test('Test 28: Reject approval for an invalid request ID', () {
    final result = service.approveRequest('INVALID-REQUEST-ID');

    expect(result, false);
    expect(service.getRequestById('INVALID-REQUEST-ID'), isNull);
  });
}
