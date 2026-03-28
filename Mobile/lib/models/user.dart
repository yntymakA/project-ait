class User {
  final int id;
  final String firebaseUid;
  final String email;
  final String fullName;
  final String? phone;
  final String role;
  final String status;
  final String? profileImageUrl;
  final String? bio;
  final String? city;
  final String? preferredLanguage;
  final double balance;
  final DateTime createdAt;

  User({
    required this.id,
    required this.firebaseUid,
    required this.email,
    required this.fullName,
    this.phone,
    required this.role,
    required this.status,
    this.profileImageUrl,
    this.bio,
    this.city,
    this.preferredLanguage,
    required this.balance,
    required this.createdAt,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as int,
      firebaseUid: json['firebase_uid'] as String,
      email: json['email'] as String,
      fullName: json['full_name'] as String,
      phone: json['phone'] as String?,
      role: json['role'] as String,
      status: json['status'] as String,
      profileImageUrl: json['profile_image_url'] as String?,
      bio: json['bio'] as String?,
      city: json['city'] as String?,
      preferredLanguage: json['preferred_language'] as String?,
      balance: double.tryParse(json['balance'].toString()) ?? 0.0,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }
}
