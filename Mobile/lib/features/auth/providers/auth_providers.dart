import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/auth_repository.dart';

final loginProvider = StateNotifierProvider<LoginNotifier, AsyncValue<void>>((ref) {
  return LoginNotifier(ref.watch(authRepositoryProvider));
});

class LoginNotifier extends StateNotifier<AsyncValue<void>> {
  final AuthRepository _repository;

  LoginNotifier(this._repository) : super(const AsyncValue.data(null));

  Future<void> login(String email, String password) async {
    state = const AsyncValue.loading();
    try {
      await _repository.signIn(email, password);
      await _repository.syncUserWithBackend();
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> register(String email, String password) async {
    state = const AsyncValue.loading();
    try {
      await _repository.signUp(email, password);
      await _repository.syncUserWithBackend();
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> logout() async {
    await _repository.signOut();
  }
}
