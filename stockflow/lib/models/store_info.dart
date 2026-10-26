enum UserRole {
  storeManager,
  warehouseManager,
}

class StoreInfo {
  final String id;
  final String name;
  final String code;
  final String location;
  final String managerName;
  final String contactPhone;

  const StoreInfo({
    required this.id,
    required this.name,
    required this.code,
    required this.location,
    required this.managerName,
    required this.contactPhone,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'code': code,
      'location': location,
      'managerName': managerName,
      'contactPhone': contactPhone,
    };
  }

  factory StoreInfo.fromMap(Map<String, dynamic> map) {
    return StoreInfo(
      id: map['id'] as String? ?? '',
      name: map['name'] as String? ?? '',
      code: map['code'] as String? ?? '',
      location: map['location'] as String? ?? '',
      managerName: map['managerName'] as String? ?? '',
      contactPhone: map['contactPhone'] as String? ?? '',
    );
  }
}
