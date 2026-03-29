/// Minimal `/users/me` payload for client-side checks (e.g. owner vs buyer).
class MeUser {
  final int id;
  final String fullName;

  const MeUser({required this.id, required this.fullName});

  factory MeUser.fromJson(Map<String, dynamic> json) {
    return MeUser(
      id: (json['id'] as num).toInt(),
      fullName: json['full_name'] as String? ?? '',
    );
  }
}
