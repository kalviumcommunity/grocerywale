enum ItemVelocity {
  fastMoving,
  mediumMoving,
  slowMoving,
}

extension ItemVelocityExtension on ItemVelocity {
  String get displayName {
    switch (this) {
      case ItemVelocity.fastMoving:
        return 'Fast Moving';
      case ItemVelocity.mediumMoving:
        return 'Standard';
      case ItemVelocity.slowMoving:
        return 'Slow Moving';
    }
  }

  bool get isFastMoving => this == ItemVelocity.fastMoving;
}

enum ItemCategory {
  dairy,
  bakery,
  produce,
  staples,
  beverages,
  packagedGoods,
}

extension ItemCategoryExtension on ItemCategory {
  String get displayName {
    switch (this) {
      case ItemCategory.dairy:
        return 'Dairy & Eggs';
      case ItemCategory.bakery:
        return 'Bakery';
      case ItemCategory.produce:
        return 'Fresh Produce';
      case ItemCategory.staples:
        return 'Staples & Grains';
      case ItemCategory.beverages:
        return 'Beverages';
      case ItemCategory.packagedGoods:
        return 'Packaged Goods';
    }
  }
}

class GroceryItem {
  final String id;
  final String name;
  final String sku;
  final ItemCategory category;
  final ItemVelocity velocity;
  final String unit;
  final double unitPrice;
  final int storeStock;
  final int warehouseStock;
  final int reorderThreshold;
  final double dailyBurnRate;
  final String? notes;

  const GroceryItem({
    required this.id,
    required this.name,
    required this.sku,
    required this.category,
    required this.velocity,
    required this.unit,
    required this.unitPrice,
    required this.storeStock,
    required this.warehouseStock,
    required this.reorderThreshold,
    required this.dailyBurnRate,
    this.notes,
  });

  bool get isLowStock => storeStock <= reorderThreshold;

  bool get isCriticalRisk {
    if (storeStock <= 0) return true;
    if (velocity == ItemVelocity.fastMoving && storeStock <= (reorderThreshold * 0.5)) {
      return true;
    }
    return hoursUntilStockout < 8.0;
  }

  double get hoursUntilStockout {
    if (dailyBurnRate <= 0) return 999.0;
    if (storeStock <= 0) return 0.0;
    final burnPerHour = dailyBurnRate / 24.0;
    return storeStock / burnPerHour;
  }

  GroceryItem copyWith({
    String? id,
    String? name,
    String? sku,
    ItemCategory? category,
    ItemVelocity? velocity,
    String? unit,
    double? unitPrice,
    int? storeStock,
    int? warehouseStock,
    int? reorderThreshold,
    double? dailyBurnRate,
    String? notes,
  }) {
    return GroceryItem(
      id: id ?? this.id,
      name: name ?? this.name,
      sku: sku ?? this.sku,
      category: category ?? this.category,
      velocity: velocity ?? this.velocity,
      unit: unit ?? this.unit,
      unitPrice: unitPrice ?? this.unitPrice,
      storeStock: storeStock ?? this.storeStock,
      warehouseStock: warehouseStock ?? this.warehouseStock,
      reorderThreshold: reorderThreshold ?? this.reorderThreshold,
      dailyBurnRate: dailyBurnRate ?? this.dailyBurnRate,
      notes: notes ?? this.notes,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'sku': sku,
      'category': category.name,
      'velocity': velocity.name,
      'unit': unit,
      'unitPrice': unitPrice,
      'storeStock': storeStock,
      'warehouseStock': warehouseStock,
      'reorderThreshold': reorderThreshold,
      'dailyBurnRate': dailyBurnRate,
      'notes': notes,
    };
  }

  factory GroceryItem.fromMap(Map<String, dynamic> map) {
    return GroceryItem(
      id: map['id'] as String? ?? '',
      name: map['name'] as String? ?? '',
      sku: map['sku'] as String? ?? '',
      category: ItemCategory.values.firstWhere(
        (e) => e.name == map['category'],
        orElse: () => ItemCategory.packagedGoods,
      ),
      velocity: ItemVelocity.values.firstWhere(
        (e) => e.name == map['velocity'],
        orElse: () => ItemVelocity.mediumMoving,
      ),
      unit: map['unit'] as String? ?? 'units',
      unitPrice: (map['unitPrice'] as num?)?.toDouble() ?? 0.0,
      storeStock: (map['storeStock'] as num?)?.toInt() ?? 0,
      warehouseStock: (map['warehouseStock'] as num?)?.toInt() ?? 0,
      reorderThreshold: (map['reorderThreshold'] as num?)?.toInt() ?? 0,
      dailyBurnRate: (map['dailyBurnRate'] as num?)?.toDouble() ?? 0.0,
      notes: map['notes'] as String?,
    );
  }
}
