/// `GET /promotions/packages` item.
class PromotionPackage {
  final int id;
  final String name;
  final String promotionType;
  final int durationDays;
  final double price;
  final bool isActive;

  const PromotionPackage({
    required this.id,
    required this.name,
    required this.promotionType,
    required this.durationDays,
    required this.price,
    required this.isActive,
  });

  factory PromotionPackage.fromJson(Map<String, dynamic> json) {
    return PromotionPackage(
      id: (json['id'] as num).toInt(),
      name: json['name'] as String? ?? '',
      promotionType: json['promotion_type'] as String? ?? '',
      durationDays: (json['duration_days'] as num?)?.toInt() ?? 0,
      price: _parseMoney(json['price']),
      isActive: json['is_active'] as bool? ?? true,
    );
  }

  static double _parseMoney(dynamic v) {
    if (v is num) return v.toDouble();
    if (v is String) return double.tryParse(v) ?? 0;
    return 0;
  }
}
