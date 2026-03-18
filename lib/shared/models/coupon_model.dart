class Coupon {
  final String id;
  final String code;
  final double discountAmount;
  final bool isPercentage;
  final double minOrderAmount;
  final double? maxDiscountAmount;
  final DateTime? expiryDate;
  final bool isActive;

  const Coupon({
    required this.id,
    required this.code,
    required this.discountAmount,
    this.isPercentage = true,
    this.minOrderAmount = 0,
    this.maxDiscountAmount,
    this.expiryDate,
    this.isActive = true,
  });

  Map<String, dynamic> toMap() => {
    'code': code,
    'discountAmount': discountAmount,
    'isPercentage': isPercentage,
    'minOrderAmount': minOrderAmount,
    'maxDiscountAmount': maxDiscountAmount,
    'expiryDate': expiryDate?.toIso8601String(),
    'isActive': isActive,
    'updatedAt': DateTime.now().toIso8601String(),
  };

  factory Coupon.fromMap(String id, Map<String, dynamic> map) {
    return Coupon(
      id: id,
      code: map['code'] as String? ?? '',
      discountAmount: (map['discountAmount'] as num?)?.toDouble() ?? 0,
      isPercentage: map['isPercentage'] as bool? ?? true,
      minOrderAmount: (map['minOrderAmount'] as num?)?.toDouble() ?? 0,
      maxDiscountAmount: (map['maxDiscountAmount'] as num?)?.toDouble(),
      expiryDate: map['expiryDate'] != null
          ? DateTime.tryParse(map['expiryDate'] as String)
          : null,
      isActive: map['isActive'] as bool? ?? true,
    );
  }

  bool isValid(double total) {
    if (!isActive) return false;
    if (expiryDate != null && expiryDate!.isBefore(DateTime.now())) return false;
    if (total < minOrderAmount) return false;
    return true;
  }

  double calculateDiscount(double total) {
    if (!isValid(total)) return 0;
    double discount = isPercentage ? (total * (discountAmount / 100)) : discountAmount;
    if (maxDiscountAmount != null && discount > maxDiscountAmount!) {
      discount = maxDiscountAmount!;
    }
    return discount;
  }
}
