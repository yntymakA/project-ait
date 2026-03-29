/// `/users/me` payload (includes balance + featured VIP badge when applicable).
class MeUser {
  final int id;
  final String fullName;
  final double balance;
  final bool hasFeaturedBadge;

  const MeUser({
    required this.id,
    required this.fullName,
    this.balance = 0,
    this.hasFeaturedBadge = false,
  });

  factory MeUser.fromJson(Map<String, dynamic> json) {
    return MeUser(
      id: (json['id'] as num).toInt(),
      fullName: json['full_name'] as String? ?? '',
      balance: _parseMoney(json['balance']),
      hasFeaturedBadge: json['has_featured_badge'] as bool? ?? false,
    );
  }

  static double _parseMoney(dynamic v) {
    if (v == null) return 0;
    if (v is num) return v.toDouble();
    if (v is String) {
      final normalized = v.replaceAll(',', '.').trim();
      return double.tryParse(normalized) ?? 0;
    }
    return 0;
  }
}
