import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/api/api_client.dart';
import '../../../core/auth/auth_provider.dart';
import '../data/me_user.dart';

/// Backend user profile for the signed-in Firebase user (`GET /users/me`).
final currentMeProvider = FutureProvider.autoDispose<MeUser?>((ref) async {
  final firebase = ref.watch(currentUserProvider);
  if (firebase == null) return null;
  final res = await dioClient.get<Map<String, dynamic>>('/users/me');
  return MeUser.fromJson(res.data!);
});
