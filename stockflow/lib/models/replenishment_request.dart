import 'grocery_item.dart';

enum ReplenishmentStatus {
  requested,
  approved,
  dispatched,
  received,
  cancelled,
}

extension ReplenishmentStatusExtension on ReplenishmentStatus {
  String get displayName {
    switch (this) {
      case ReplenishmentStatus.requested:
        return 'Requested';
      case ReplenishmentStatus.approved:
        return 'Approved';
      case ReplenishmentStatus.dispatched:
        return 'Dispatched';
      case ReplenishmentStatus.received:
        return 'Received';
      case ReplenishmentStatus.cancelled:
        return 'Cancelled';
    }
  }

  int get stepIndex {
    switch (this) {
      case ReplenishmentStatus.requested:
        return 0;
      case ReplenishmentStatus.approved:
        return 1;
      case ReplenishmentStatus.dispatched:
        return 2;
      case ReplenishmentStatus.received:
        return 3;
      case ReplenishmentStatus.cancelled:
        return -1;
    }
  }
}

enum ReplenishmentPriority {
  urgentFastMoving,
  high,
  standard,
}

extension ReplenishmentPriorityExtension on ReplenishmentPriority {
  String get displayName {
    switch (this) {
      case ReplenishmentPriority.urgentFastMoving:
        return '⚡ Urgent (Fast-Moving Stockout)';
      case ReplenishmentPriority.high:
        return 'High Priority';
      case ReplenishmentPriority.standard:
        return 'Standard Cycle';
    }
  }

  bool get isUrgent => this == ReplenishmentPriority.urgentFastMoving || this == ReplenishmentPriority.high;
}

class ReplenishmentItem {
  final String itemId;
  final String itemName;
  final String sku;
  final String unit;
  final bool isFastMoving;
  final int requestedQuantity;
  final int approvedQuantity;
  final int receivedQuantity;
  final double unitPrice;

  const ReplenishmentItem({
    required this.itemId,
    required this.itemName,
    required this.sku,
    required this.unit,
    required this.isFastMoving,
    required this.requestedQuantity,
    this.approvedQuantity = 0,
    this.receivedQuantity = 0,
    required this.unitPrice,
  });

  ReplenishmentItem copyWith({
    String? itemId,
    String? itemName,
    String? sku,
    String? unit,
    bool? isFastMoving,
    int? requestedQuantity,
    int? approvedQuantity,
    int? receivedQuantity,
    double? unitPrice,
  }) {
    return ReplenishmentItem(
      itemId: itemId ?? this.itemId,
      itemName: itemName ?? this.itemName,
      sku: sku ?? this.sku,
      unit: unit ?? this.unit,
      isFastMoving: isFastMoving ?? this.isFastMoving,
      requestedQuantity: requestedQuantity ?? this.requestedQuantity,
      approvedQuantity: approvedQuantity ?? this.approvedQuantity,
      receivedQuantity: receivedQuantity ?? this.receivedQuantity,
      unitPrice: unitPrice ?? this.unitPrice,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'itemId': itemId,
      'itemName': itemName,
      'sku': sku,
      'unit': unit,
      'isFastMoving': isFastMoving,
      'requestedQuantity': requestedQuantity,
      'approvedQuantity': approvedQuantity,
      'receivedQuantity': receivedQuantity,
      'unitPrice': unitPrice,
    };
  }

  factory ReplenishmentItem.fromMap(Map<String, dynamic> map) {
    return ReplenishmentItem(
      itemId: map['itemId'] as String? ?? '',
      itemName: map['itemName'] as String? ?? '',
      sku: map['sku'] as String? ?? '',
      unit: map['unit'] as String? ?? 'units',
      isFastMoving: map['isFastMoving'] as bool? ?? false,
      requestedQuantity: (map['requestedQuantity'] as num?)?.toInt() ?? 0,
      approvedQuantity: (map['approvedQuantity'] as num?)?.toInt() ?? 0,
      receivedQuantity: (map['receivedQuantity'] as num?)?.toInt() ?? 0,
      unitPrice: (map['unitPrice'] as num?)?.toDouble() ?? 0.0,
    );
  }

  factory ReplenishmentItem.fromGroceryItem(GroceryItem item, int quantity) {
    return ReplenishmentItem(
      itemId: item.id,
      itemName: item.name,
      sku: item.sku,
      unit: item.unit,
      isFastMoving: item.velocity == ItemVelocity.fastMoving,
      requestedQuantity: quantity,
      approvedQuantity: quantity,
      receivedQuantity: 0,
      unitPrice: item.unitPrice,
    );
  }
}

class ReplenishmentRequest {
  final String id;
  final String storeId;
  final String storeName;
  final ReplenishmentStatus status;
  final ReplenishmentPriority priority;
  final List<ReplenishmentItem> items;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? approvedAt;
  final String? approvedBy;
  final DateTime? dispatchedAt;
  final String? trackingReference;
  final String? carrierName;
  final DateTime? estimatedDeliveryAt;
  final DateTime? receivedAt;
  final String? receivedBy;
  final String? notes;

  const ReplenishmentRequest({
    required this.id,
    required this.storeId,
    required this.storeName,
    required this.status,
    required this.priority,
    required this.items,
    required this.createdAt,
    required this.updatedAt,
    this.approvedAt,
    this.approvedBy,
    this.dispatchedAt,
    this.trackingReference,
    this.carrierName,
    this.estimatedDeliveryAt,
    this.receivedAt,
    this.receivedBy,
    this.notes,
  });

  bool get containsFastMoving => items.any((i) => i.isFastMoving);

  int get totalRequestedUnits => items.fold(0, (sum, i) => sum + i.requestedQuantity);

  int get totalApprovedUnits => items.fold(0, (sum, i) => sum + i.approvedQuantity);

  double get estimatedTotalValue =>
      items.fold(0.0, (sum, i) => sum + (i.requestedQuantity * i.unitPrice));

  ReplenishmentRequest copyWith({
    String? id,
    String? storeId,
    String? storeName,
    ReplenishmentStatus? status,
    ReplenishmentPriority? priority,
    List<ReplenishmentItem>? items,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? approvedAt,
    String? approvedBy,
    DateTime? dispatchedAt,
    String? trackingReference,
    String? carrierName,
    DateTime? estimatedDeliveryAt,
    DateTime? receivedAt,
    String? receivedBy,
    String? notes,
  }) {
    return ReplenishmentRequest(
      id: id ?? this.id,
      storeId: storeId ?? this.storeId,
      storeName: storeName ?? this.storeName,
      status: status ?? this.status,
      priority: priority ?? this.priority,
      items: items ?? this.items,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      approvedAt: approvedAt ?? this.approvedAt,
      approvedBy: approvedBy ?? this.approvedBy,
      dispatchedAt: dispatchedAt ?? this.dispatchedAt,
      trackingReference: trackingReference ?? this.trackingReference,
      carrierName: carrierName ?? this.carrierName,
      estimatedDeliveryAt: estimatedDeliveryAt ?? this.estimatedDeliveryAt,
      receivedAt: receivedAt ?? this.receivedAt,
      receivedBy: receivedBy ?? this.receivedBy,
      notes: notes ?? this.notes,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'storeId': storeId,
      'storeName': storeName,
      'status': status.name,
      'priority': priority.name,
      'items': items.map((i) => i.toMap()).toList(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'approvedAt': approvedAt?.toIso8601String(),
      'approvedBy': approvedBy,
      'dispatchedAt': dispatchedAt?.toIso8601String(),
      'trackingReference': trackingReference,
      'carrierName': carrierName,
      'estimatedDeliveryAt': estimatedDeliveryAt?.toIso8601String(),
      'receivedAt': receivedAt?.toIso8601String(),
      'receivedBy': receivedBy,
      'notes': notes,
    };
  }

  factory ReplenishmentRequest.fromMap(Map<String, dynamic> map) {
    return ReplenishmentRequest(
      id: map['id'] as String? ?? '',
      storeId: map['storeId'] as String? ?? '',
      storeName: map['storeName'] as String? ?? '',
      status: ReplenishmentStatus.values.firstWhere(
        (e) => e.name == map['status'],
        orElse: () => ReplenishmentStatus.requested,
      ),
      priority: ReplenishmentPriority.values.firstWhere(
        (e) => e.name == map['priority'],
        orElse: () => ReplenishmentPriority.standard,
      ),
      items: (map['items'] as List<dynamic>?)
              ?.map((i) => ReplenishmentItem.fromMap(i as Map<String, dynamic>))
              .toList() ??
          [],
      createdAt: DateTime.tryParse(map['createdAt'] as String? ?? '') ?? DateTime.now(),
      updatedAt: DateTime.tryParse(map['updatedAt'] as String? ?? '') ?? DateTime.now(),
      approvedAt: map['approvedAt'] != null ? DateTime.tryParse(map['approvedAt']) : null,
      approvedBy: map['approvedBy'] as String?,
      dispatchedAt: map['dispatchedAt'] != null ? DateTime.tryParse(map['dispatchedAt']) : null,
      trackingReference: map['trackingReference'] as String?,
      carrierName: map['carrierName'] as String?,
      estimatedDeliveryAt:
          map['estimatedDeliveryAt'] != null ? DateTime.tryParse(map['estimatedDeliveryAt']) : null,
      receivedAt: map['receivedAt'] != null ? DateTime.tryParse(map['receivedAt']) : null,
      receivedBy: map['receivedBy'] as String?,
      notes: map['notes'] as String?,
    );
  }
}
