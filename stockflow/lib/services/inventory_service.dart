import 'package:flutter/foundation.dart';
import '../models/grocery_item.dart';
import '../models/replenishment_request.dart';
import '../models/store_info.dart';

class InventoryService extends ChangeNotifier {
  static final InventoryService _instance = InventoryService._internal();
  factory InventoryService() => _instance;

  InventoryService._internal() {
    _initData();
  }

  UserRole _currentRole = UserRole.storeManager;
  UserRole get currentRole => _currentRole;

  late StoreInfo _currentStore;
  StoreInfo get currentStore => _currentStore;

  List<StoreInfo> _stores = [];
  List<StoreInfo> get stores => List.unmodifiable(_stores);

  List<GroceryItem> _catalog = [];
  List<GroceryItem> get catalog => List.unmodifiable(_catalog);

  List<ReplenishmentRequest> _requests = [];
  List<ReplenishmentRequest> get requests => List.unmodifiable(_requests);

  int _requestCounter = 1000;

  // Preferences & User Settings
  bool _stockoutAlertsEnabled = true;
  bool get stockoutAlertsEnabled => _stockoutAlertsEnabled;

  bool _autoReorderSuggestions = true;
  bool get autoReorderSuggestions => _autoReorderSuggestions;

  bool _soundAlertsEnabled = false;
  bool get soundAlertsEnabled => _soundAlertsEnabled;

  void toggleStockoutAlerts(bool value) {
    _stockoutAlertsEnabled = value;
    notifyListeners();
  }

  void toggleAutoReorder(bool value) {
    _autoReorderSuggestions = value;
    notifyListeners();
  }

  void toggleSoundAlerts(bool value) {
    _soundAlertsEnabled = value;
    notifyListeners();
  }

  String get currentUserName =>
      _currentRole == UserRole.storeManager ? _currentStore.managerName : 'Marcus Vance';

  String get currentUserEmail => _currentRole == UserRole.storeManager
      ? '${_currentStore.managerName.toLowerCase().replaceAll(' ', '.')}@grocerywale.com'
      : 'marcus.vance@grocerywale.com';

  String get currentUserPhone =>
      _currentRole == UserRole.storeManager ? _currentStore.contactPhone : '+1 555-0199';

  String get currentEmployeeId =>
      _currentRole == UserRole.storeManager ? 'GW-${_currentStore.code}' : 'GW-WH-001';

  String get currentRoleTitle =>
      _currentRole == UserRole.storeManager ? 'Store Manager' : 'Central Warehouse Supervisor';

  void resetDemoData() {
    _initData();
    notifyListeners();
  }

  void setRole(UserRole role) {
    if (_currentRole != role) {
      _currentRole = role;
      notifyListeners();
    }
  }

  void setActiveStore(StoreInfo store) {
    _currentStore = store;
    notifyListeners();
  }

  void _initData() {
    _stores = [
      const StoreInfo(
        id: 'store_101',
        name: 'Metro Downtown',
        code: 'STR-101',
        location: '45 Market Street, Central City',
        managerName: 'Sarah Jenkins',
        contactPhone: '+1 555-0101',
      ),
      const StoreInfo(
        id: 'store_102',
        name: 'Westside Supercenter',
        code: 'STR-102',
        location: '880 West Highway, District 4',
        managerName: 'David Chen',
        contactPhone: '+1 555-0102',
      ),
      const StoreInfo(
        id: 'store_103',
        name: 'Suburban Plaza',
        code: 'STR-103',
        location: '12 Oak Avenue, Green Valley',
        managerName: 'Priya Sharma',
        contactPhone: '+1 555-0103',
      ),
    ];

    _currentStore = _stores[0];

    // Catalog with realistic grocery items highlighting fast-moving goods
    _catalog = [
      const GroceryItem(
        id: 'item_milk_1l',
        name: 'Whole Fresh Milk 1L',
        sku: 'DAI-MLK-001',
        category: ItemCategory.dairy,
        velocity: ItemVelocity.fastMoving,
        unit: 'crates (12pk)',
        unitPrice: 24.50,
        storeStock: 4, // Critical! threshold is 25, burns fast
        warehouseStock: 450,
        reorderThreshold: 25,
        dailyBurnRate: 35.0,
        notes: 'Top daily revenue generator. Stockout in ~2.7 hours!',
      ),
      const GroceryItem(
        id: 'item_bread_sliced',
        name: 'Artisan Sliced Sandwich Bread',
        sku: 'BAK-BRD-002',
        category: ItemCategory.bakery,
        velocity: ItemVelocity.fastMoving,
        unit: 'crates (20 loaves)',
        unitPrice: 32.00,
        storeStock: 6, // Critical!
        warehouseStock: 320,
        reorderThreshold: 20,
        dailyBurnRate: 28.0,
        notes: 'Daily delivery essential; fast turnover item.',
      ),
      const GroceryItem(
        id: 'item_eggs_doz',
        name: 'Farm Fresh Brown Eggs (Dozen)',
        sku: 'DAI-EGG-003',
        category: ItemCategory.dairy,
        velocity: ItemVelocity.fastMoving,
        unit: 'cases (30 doz)',
        unitPrice: 75.00,
        storeStock: 8,
        warehouseStock: 280,
        reorderThreshold: 30,
        dailyBurnRate: 25.0,
        notes: 'High demand staple breakfast product.',
      ),
      const GroceryItem(
        id: 'item_bananas',
        name: 'Organic Cavendish Bananas',
        sku: 'PRD-BAN-004',
        category: ItemCategory.produce,
        velocity: ItemVelocity.fastMoving,
        unit: 'crates (18 kg)',
        unitPrice: 22.00,
        storeStock: 12,
        warehouseStock: 500,
        reorderThreshold: 35,
        dailyBurnRate: 40.0,
        notes: 'Perishable fast-turn produce.',
      ),
      const GroceryItem(
        id: 'item_water_pack',
        name: 'Spring Water (24 x 500ml)',
        sku: 'BEV-WTR-005',
        category: ItemCategory.beverages,
        velocity: ItemVelocity.fastMoving,
        unit: 'cases (24 bottles)',
        unitPrice: 14.50,
        storeStock: 15,
        warehouseStock: 600,
        reorderThreshold: 40,
        dailyBurnRate: 30.0,
        notes: 'Summer volume driver.',
      ),
      const GroceryItem(
        id: 'item_rice_basmati',
        name: 'Premium Basmati Rice 5kg',
        sku: 'STP-RIC-006',
        category: ItemCategory.staples,
        velocity: ItemVelocity.mediumMoving,
        unit: 'bags (5kg)',
        unitPrice: 18.00,
        storeStock: 45,
        warehouseStock: 350,
        reorderThreshold: 30,
        dailyBurnRate: 10.0,
        notes: 'Core grocery staple.',
      ),
      const GroceryItem(
        id: 'item_sunflower_oil',
        name: 'Refined Sunflower Cooking Oil 1L',
        sku: 'STP-OIL-007',
        category: ItemCategory.staples,
        velocity: ItemVelocity.mediumMoving,
        unit: 'cartons (12 x 1L)',
        unitPrice: 38.00,
        storeStock: 28,
        warehouseStock: 220,
        reorderThreshold: 25,
        dailyBurnRate: 8.0,
        notes: 'Weekly household restock item.',
      ),
      const GroceryItem(
        id: 'item_greek_yogurt',
        name: 'Greek Style Plain Yogurt 500g',
        sku: 'DAI-YOG-008',
        category: ItemCategory.dairy,
        velocity: ItemVelocity.fastMoving,
        unit: 'crates (12 tubs)',
        unitPrice: 28.00,
        storeStock: 9,
        warehouseStock: 190,
        reorderThreshold: 20,
        dailyBurnRate: 15.0,
        notes: 'Short shelf life, high repeat purchase.',
      ),
      const GroceryItem(
        id: 'item_potato_chips',
        name: 'Crispy Salted Potato Chips 150g',
        sku: 'PKG-CHP-009',
        category: ItemCategory.packagedGoods,
        velocity: ItemVelocity.mediumMoving,
        unit: 'cartons (24 bags)',
        unitPrice: 26.00,
        storeStock: 34,
        warehouseStock: 280,
        reorderThreshold: 20,
        dailyBurnRate: 7.0,
        notes: 'Snack aisle staple.',
      ),
      const GroceryItem(
        id: 'item_coffee_beans',
        name: 'Signature Arabica Coffee Beans 1kg',
        sku: 'PKG-COF-010',
        category: ItemCategory.packagedGoods,
        velocity: ItemVelocity.slowMoving,
        unit: 'cartons (6 x 1kg)',
        unitPrice: 65.00,
        storeStock: 18,
        warehouseStock: 110,
        reorderThreshold: 10,
        dailyBurnRate: 2.0,
        notes: 'Higher margin, slower cyclic velocity.',
      ),
    ];

    // Seed realistic restock requests across statuses
    final now = DateTime.now();

    _requests = [
      ReplenishmentRequest(
        id: 'REQ-2026-0891',
        storeId: 'store_101',
        storeName: 'Metro Downtown',
        status: ReplenishmentStatus.dispatched,
        priority: ReplenishmentPriority.urgentFastMoving,
        createdAt: now.subtract(const Duration(hours: 4, minutes: 15)),
        updatedAt: now.subtract(const Duration(hours: 1)),
        approvedAt: now.subtract(const Duration(hours: 3)),
        approvedBy: 'Marcus Vance (Central Warehouse)',
        dispatchedAt: now.subtract(const Duration(hours: 1, minutes: 10)),
        carrierName: 'FastTrack Fleet #14 (Refrigerated)',
        trackingReference: 'TRK-9812-EXP',
        estimatedDeliveryAt: now.add(const Duration(minutes: 45)),
        notes: 'URGENT: Store milk and eggs down to critical minimums before evening rush.',
        items: [
          ReplenishmentItem(
            itemId: 'item_milk_1l',
            itemName: 'Whole Fresh Milk 1L',
            sku: 'DAI-MLK-001',
            unit: 'crates (12pk)',
            isFastMoving: true,
            requestedQuantity: 30,
            approvedQuantity: 30,
            receivedQuantity: 0,
            unitPrice: 24.50,
          ),
          ReplenishmentItem(
            itemId: 'item_bread_sliced',
            itemName: 'Artisan Sliced Sandwich Bread',
            sku: 'BAK-BRD-002',
            unit: 'crates (20 loaves)',
            isFastMoving: true,
            requestedQuantity: 20,
            approvedQuantity: 20,
            receivedQuantity: 0,
            unitPrice: 32.00,
          ),
        ],
      ),
      ReplenishmentRequest(
        id: 'REQ-2026-0892',
        storeId: 'store_101',
        storeName: 'Metro Downtown',
        status: ReplenishmentStatus.requested,
        priority: ReplenishmentPriority.urgentFastMoving,
        createdAt: now.subtract(const Duration(minutes: 50)),
        updatedAt: now.subtract(const Duration(minutes: 50)),
        notes: 'Emergency restock for Bananas & Eggs - shelf will be empty in 3 hours.',
        items: [
          ReplenishmentItem(
            itemId: 'item_eggs_doz',
            itemName: 'Farm Fresh Brown Eggs (Dozen)',
            sku: 'DAI-EGG-003',
            unit: 'cases (30 doz)',
            isFastMoving: true,
            requestedQuantity: 25,
            approvedQuantity: 0,
            receivedQuantity: 0,
            unitPrice: 75.00,
          ),
          ReplenishmentItem(
            itemId: 'item_bananas',
            itemName: 'Organic Cavendish Bananas',
            sku: 'PRD-BAN-004',
            unit: 'crates (18 kg)',
            isFastMoving: true,
            requestedQuantity: 25,
            approvedQuantity: 0,
            receivedQuantity: 0,
            unitPrice: 22.00,
          ),
        ],
      ),
      ReplenishmentRequest(
        id: 'REQ-2026-0888',
        storeId: 'store_102',
        storeName: 'Westside Supercenter',
        status: ReplenishmentStatus.approved,
        priority: ReplenishmentPriority.standard,
        createdAt: now.subtract(const Duration(hours: 7)),
        updatedAt: now.subtract(const Duration(hours: 2, minutes: 20)),
        approvedAt: now.subtract(const Duration(hours: 2, minutes: 20)),
        approvedBy: 'Marcus Vance (Central Warehouse)',
        carrierName: 'Central Logistics Truck #04',
        estimatedDeliveryAt: now.add(const Duration(hours: 3)),
        notes: 'Bi-weekly staples and cooking oil replenishment cycle.',
        items: [
          ReplenishmentItem(
            itemId: 'item_rice_basmati',
            itemName: 'Premium Basmati Rice 5kg',
            sku: 'STP-RIC-006',
            unit: 'bags (5kg)',
            isFastMoving: false,
            requestedQuantity: 40,
            approvedQuantity: 40,
            receivedQuantity: 0,
            unitPrice: 18.00,
          ),
          ReplenishmentItem(
            itemId: 'item_sunflower_oil',
            itemName: 'Refined Sunflower Cooking Oil 1L',
            sku: 'STP-OIL-007',
            unit: 'cartons (12 x 1L)',
            isFastMoving: false,
            requestedQuantity: 30,
            approvedQuantity: 25, // Adjusted by warehouse
            receivedQuantity: 0,
            unitPrice: 38.00,
          ),
        ],
      ),
      ReplenishmentRequest(
        id: 'REQ-2026-0880',
        storeId: 'store_101',
        storeName: 'Metro Downtown',
        status: ReplenishmentStatus.received,
        priority: ReplenishmentPriority.standard,
        createdAt: now.subtract(const Duration(days: 1, hours: 6)),
        updatedAt: now.subtract(const Duration(hours: 14)),
        approvedAt: now.subtract(const Duration(days: 1, hours: 2)),
        approvedBy: 'Marcus Vance (Central Warehouse)',
        dispatchedAt: now.subtract(const Duration(hours: 18)),
        receivedAt: now.subtract(const Duration(hours: 14)),
        receivedBy: 'Sarah Jenkins (Store Manager)',
        trackingReference: 'TRK-9621-REG',
        carrierName: 'Central Express #09',
        notes: 'Standard packaged goods stock cycle received in full.',
        items: [
          ReplenishmentItem(
            itemId: 'item_water_pack',
            itemName: 'Spring Water (24 x 500ml)',
            sku: 'BEV-WTR-005',
            unit: 'cases (24 bottles)',
            isFastMoving: true,
            requestedQuantity: 35,
            approvedQuantity: 35,
            receivedQuantity: 35,
            unitPrice: 14.50,
          ),
          ReplenishmentItem(
            itemId: 'item_potato_chips',
            itemName: 'Crispy Salted Potato Chips 150g',
            sku: 'PKG-CHP-009',
            unit: 'cartons (24 bags)',
            isFastMoving: false,
            requestedQuantity: 20,
            approvedQuantity: 20,
            receivedQuantity: 20,
            unitPrice: 26.00,
          ),
        ],
      ),
    ];
  }

  // Stockout Risk Insights
  List<GroceryItem> get fastMovingItemsAtRisk {
    return _catalog
        .where((item) => item.velocity == ItemVelocity.fastMoving && (item.isLowStock || item.isCriticalRisk))
        .toList()
      ..sort((a, b) => a.hoursUntilStockout.compareTo(b.hoursUntilStockout));
  }

  List<GroceryItem> get criticalItems {
    return _catalog.where((item) => item.isCriticalRisk).toList();
  }

  // Request Filtering
  List<ReplenishmentRequest> getRequestsForRole({
    ReplenishmentStatus? statusFilter,
    bool onlyCurrentStore = false,
    bool fastMovingOnly = false,
  }) {
    Iterable<ReplenishmentRequest> list = _requests;

    if (onlyCurrentStore || _currentRole == UserRole.storeManager) {
      list = list.where((r) => r.storeId == _currentStore.id);
    }

    if (statusFilter != null) {
      list = list.where((r) => r.status == statusFilter);
    }

    if (fastMovingOnly) {
      list = list.where((r) => r.containsFastMoving);
    }

    final sorted = list.toList();
    // Prioritize urgent fast moving orders first, then chronologically newest
    sorted.sort((a, b) {
      if (a.priority == ReplenishmentPriority.urgentFastMoving &&
          b.priority != ReplenishmentPriority.urgentFastMoving) {
        return -1;
      }
      if (b.priority == ReplenishmentPriority.urgentFastMoving &&
          a.priority != ReplenishmentPriority.urgentFastMoving) {
        return 1;
      }
      return b.createdAt.compareTo(a.createdAt);
    });

    return sorted;
  }

  ReplenishmentRequest? getRequestById(String id) {
    try {
      return _requests.firstWhere((r) => r.id == id);
    } catch (_) {
      return null;
    }
  }

  // Actions
  ReplenishmentRequest createRequest({
    required List<ReplenishmentItem> items,
    required ReplenishmentPriority priority,
    String? notes,
    StoreInfo? forStore,
  }) {
    final targetStore = forStore ?? _currentStore;
    final now = DateTime.now();
    _requestCounter++;
    final newId = 'REQ-2026-${_requestCounter.toString().padLeft(4, '0')}';

    final newRequest = ReplenishmentRequest(
      id: newId,
      storeId: targetStore.id,
      storeName: targetStore.name,
      status: ReplenishmentStatus.requested,
      priority: priority,
      items: items,
      createdAt: now,
      updatedAt: now,
      notes: notes,
    );

    _requests.insert(0, newRequest);
    notifyListeners();
    return newRequest;
  }

  void quickRestockFastMovingItem(GroceryItem item, {int? quantity}) {
    final qty = quantity ?? (item.reorderThreshold * 1.5).ceil();
    final reqItem = ReplenishmentItem.fromGroceryItem(item, qty);

    createRequest(
      items: [reqItem],
      priority: ReplenishmentPriority.urgentFastMoving,
      notes: 'AUTOMATED 1-TAP EMERGENCY RESTOCK: ${item.name} is running out (${item.storeStock} ${item.unit} remaining). Stockout projected in ${item.hoursUntilStockout.toStringAsFixed(1)}h.',
    );
  }

  bool approveRequest(
    String requestId, {
    Map<String, int>? allocatedQuantities,
    String? approvedBy,
  }) {
    final index = _requests.indexWhere((r) => r.id == requestId);
    if (index == -1) return false;

    final req = _requests[index];
    if (req.status != ReplenishmentStatus.requested) return false;

    final now = DateTime.now();
    final updatedItems = <ReplenishmentItem>[];

    // Check and deduct from warehouse inventory
    for (final item in req.items) {
      final allocated = allocatedQuantities?[item.itemId] ?? item.requestedQuantity;
      final catalogIdx = _catalog.indexWhere((c) => c.id == item.itemId);

      if (catalogIdx != -1) {
        final currentCatalogItem = _catalog[catalogIdx];
        final deductQty = allocated.clamp(0, currentCatalogItem.warehouseStock);
        _catalog[catalogIdx] = currentCatalogItem.copyWith(
          warehouseStock: currentCatalogItem.warehouseStock - deductQty,
        );
        updatedItems.add(item.copyWith(approvedQuantity: deductQty));
      } else {
        updatedItems.add(item.copyWith(approvedQuantity: allocated));
      }
    }

    _requests[index] = req.copyWith(
      status: ReplenishmentStatus.approved,
      approvedAt: now,
      updatedAt: now,
      approvedBy: approvedBy ?? 'Warehouse Supervisor',
      items: updatedItems,
    );

    notifyListeners();
    return true;
  }

  bool dispatchRequest(
    String requestId, {
    required String trackingReference,
    required String carrierName,
    DateTime? estimatedDeliveryAt,
  }) {
    final index = _requests.indexWhere((r) => r.id == requestId);
    if (index == -1) return false;

    final req = _requests[index];
    if (req.status != ReplenishmentStatus.approved) return false;

    final now = DateTime.now();
    final eta = estimatedDeliveryAt ?? now.add(const Duration(hours: 2));

    _requests[index] = req.copyWith(
      status: ReplenishmentStatus.dispatched,
      dispatchedAt: now,
      updatedAt: now,
      trackingReference: trackingReference,
      carrierName: carrierName,
      estimatedDeliveryAt: eta,
    );

    notifyListeners();
    return true;
  }

  bool markReceived(String requestId, {String? receivedBy}) {
    final index = _requests.indexWhere((r) => r.id == requestId);
    if (index == -1) return false;

    final req = _requests[index];
    if (req.status != ReplenishmentStatus.dispatched) return false;

    final now = DateTime.now();
    final updatedItems = <ReplenishmentItem>[];

    // Increment store stock
    for (final item in req.items) {
      final catalogIdx = _catalog.indexWhere((c) => c.id == item.itemId);
      final receivedQty = item.approvedQuantity;

      if (catalogIdx != -1) {
        final current = _catalog[catalogIdx];
        _catalog[catalogIdx] = current.copyWith(
          storeStock: current.storeStock + receivedQty,
        );
      }
      updatedItems.add(item.copyWith(receivedQuantity: receivedQty));
    }

    _requests[index] = req.copyWith(
      status: ReplenishmentStatus.received,
      receivedAt: now,
      updatedAt: now,
      receivedBy: receivedBy ?? '${_currentStore.managerName} (Store Manager)',
      items: updatedItems,
    );

    notifyListeners();
    return true;
  }

  bool cancelRequest(String requestId, {String? reason}) {
    final index = _requests.indexWhere((r) => r.id == requestId);
    if (index == -1) return false;

    final req = _requests[index];
    if (req.status == ReplenishmentStatus.received || req.status == ReplenishmentStatus.cancelled) {
      return false;
    }

    // If was approved or dispatched, return allocated stock to warehouse
    if (req.status == ReplenishmentStatus.approved || req.status == ReplenishmentStatus.dispatched) {
      for (final item in req.items) {
        final catalogIdx = _catalog.indexWhere((c) => c.id == item.itemId);
        if (catalogIdx != -1) {
          final current = _catalog[catalogIdx];
          _catalog[catalogIdx] = current.copyWith(
            warehouseStock: current.warehouseStock + item.approvedQuantity,
          );
        }
      }
    }

    final now = DateTime.now();
    _requests[index] = req.copyWith(
      status: ReplenishmentStatus.cancelled,
      updatedAt: now,
      notes: reason != null ? '${req.notes ?? ''} [Cancelled: $reason]' : req.notes,
    );

    notifyListeners();
    return true;
  }
}
