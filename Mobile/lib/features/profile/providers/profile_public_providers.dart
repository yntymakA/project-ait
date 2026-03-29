import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/models/public_profile.dart';
import '../data/repositories/user_public_repository.dart';

final userPublicRepositoryProvider = Provider<UserPublicRepository>((ref) {
  return UserPublicRepository();
});

final publicProfileProvider =
    FutureProvider.family<PublicProfile, int>((ref, userId) async {
  return ref.read(userPublicRepositoryProvider).getPublicProfile(userId);
});
