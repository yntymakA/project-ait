class PublicProfile {
  final int id;
  final String fullName;
  final String? profileImageUrl;
  final String? city;
  final DateTime memberSince;
  final int activeListingCount;

  PublicProfile({
    required this.id,
    required this.fullName,
    this.profileImageUrl,
    this.city,
    required this.memberSince,
    required this.activeListingCount,
  });

  factory PublicProfile.fromJson(Map<String, dynamic> json) {
    return PublicProfile(
      id: (json['id'] as num).toInt(),
      fullName: json['full_name'] as String? ?? 'Seller',
      profileImageUrl: json['profile_image_url'] as String?,
      city: json['city'] as String?,
      memberSince: DateTime.parse(json['member_since'] as String),
      activeListingCount: (json['active_listing_count'] as num?)?.toInt() ?? 0,
    );
  }
}
