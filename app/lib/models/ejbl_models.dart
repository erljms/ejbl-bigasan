enum UserRole {
  staff,
  manager,
  admin;

  static UserRole fromString(String value) {
    return UserRole.values.firstWhere(
      (r) => r.name == value.toLowerCase(),
      orElse: () => UserRole.staff,
    );
  }

  String get label => switch (this) {
        UserRole.staff => 'Employee / Staff',
        UserRole.manager => 'Manager',
        UserRole.admin => 'Admin / Owner',
      };
}

class UserProfile {
  final String id;
  final String fullName;
  final UserRole role;
  final bool isActive;

  const UserProfile({
    required this.id,
    required this.fullName,
    required this.role,
    required this.isActive,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      id: json['id'] as String,
      fullName: json['full_name'] as String,
      role: UserRole.fromString(json['role'] as String),
      isActive: (json['is_active'] as bool?) ?? true,
    );
  }
}

class InventorySummaryItem {
  final String riceVarietyId;
  final String code;
  final String name;
  final double sackWeightKg;
  final double wholesaleSackPrice;
  final double retailSackPrice;
  final double wholesaleKgPrice;
  final double retailKgPrice;
  final double orderingPointKg;
  final double totalRemainingKg;
  final double remainingSacks;
  final bool isLowStock;

  const InventorySummaryItem({
    required this.riceVarietyId,
    required this.code,
    required this.name,
    required this.sackWeightKg,
    required this.wholesaleSackPrice,
    required this.retailSackPrice,
    required this.wholesaleKgPrice,
    required this.retailKgPrice,
    required this.orderingPointKg,
    required this.totalRemainingKg,
    required this.remainingSacks,
    required this.isLowStock,
  });

  factory InventorySummaryItem.fromJson(Map<String, dynamic> json) {
    double toDouble(dynamic v) => (v as num?)?.toDouble() ?? 0.0;
    return InventorySummaryItem(
      riceVarietyId: json['rice_variety_id'] as String,
      code: json['code'] as String,
      name: json['name'] as String,
      sackWeightKg: toDouble(json['sack_weight_kg']),
      wholesaleSackPrice: toDouble(json['wholesale_sack_price']),
      retailSackPrice: toDouble(json['retail_sack_price']),
      wholesaleKgPrice: toDouble(json['wholesale_kg_price']),
      retailKgPrice: toDouble(json['retail_kg_price']),
      orderingPointKg: toDouble(json['ordering_point_kg']),
      totalRemainingKg: toDouble(json['total_remaining_kg']),
      remainingSacks: toDouble(json['remaining_sacks']),
      isLowStock: (json['is_low_stock'] as bool?) ?? false,
    );
  }
}

class SaleItemInput {
  final String riceVarietyId;
  final double qtyInput;
  final String unit; // 'SACK' | 'KG'
  final double? appliedPricePerKg;

  const SaleItemInput({
    required this.riceVarietyId,
    required this.qtyInput,
    required this.unit,
    this.appliedPricePerKg,
  });

  Map<String, dynamic> toJson() => {
        'rice_variety_id': riceVarietyId,
        'qty_input': qtyInput,
        'unit': unit,
        if (appliedPricePerKg != null)
          'applied_price_per_kg': appliedPricePerKg,
      };
}

class PaymentInput {
  final String method; // 'cash' | 'gcash' | 'bank_transfer'
  final double amount;
  final String? referenceNo;

  const PaymentInput({
    required this.method,
    required this.amount,
    this.referenceNo,
  });

  Map<String, dynamic> toJson() => {
        'method': method,
        'amount': amount,
        'reference_no': referenceNo,
      };
}
