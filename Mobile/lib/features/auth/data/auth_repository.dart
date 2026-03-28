import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/api/api_client.dart';
import '../../core/auth/auth_provider.dart';

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository(
    dio: ref.watch(dioProvider),
    firebaseAuth: ref.watch(firebaseAuthProvider),
  );
});

class AuthRepository {
  final Dio dio;
  final FirebaseAuth firebaseAuth;

  AuthRepository({required this.dio, required this.firebaseAuth});

  /// Logs in via Firebase Auth (Email/Password for this example)
  Future<UserCredential> signIn(String email, String password) async {
    return await firebaseAuth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  /// Registers via Firebase Auth
  Future<UserCredential> signUp(String email, String password) async {
    return await firebaseAuth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  /// Syncs Firebase user to Backend DB.
  /// Called immediately after a successful sign-up or sign-in.
  Future<void> syncUserWithBackend() async {
    try {
      // The Interceptor attached to Dio will automatically attach
      // the Bearer token because the user is now authenticated in Firebase.
      final response = await dio.post('/users/sync');
      if (response.statusCode != 200) {
        throw Exception('Failed to sync user with backend');
      }
    } on DioException catch (e) {
      throw Exception('Network error during sync: ${e.message}');
    }
  }

  Future<void> signOut() async {
    await firebaseAuth.signOut();
  }
}
