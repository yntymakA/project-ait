import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../../../core/api/api_client.dart';

// Represents the state of our authentication actions
class AuthState {
  final bool isLoading;
  final String? error;
  const AuthState({this.isLoading = false, this.error});
}

final loginProvider = NotifierProvider<LoginNotifier, AuthState>(LoginNotifier.new);

class LoginNotifier extends Notifier<AuthState> {
  @override
  AuthState build() => const AuthState();

  FirebaseAuth get _auth {
    try {
      return FirebaseAuth.instance;
    } catch (e) {
      throw Exception('Firebase is not configured! Please run flutterfire configure.');
    }
  }

  final GoogleSignIn _googleSignIn = GoogleSignIn();

  Future<void> login(String email, String password) async {
    state = const AuthState(isLoading: true);
    try {
      final cred = await _auth.signInWithEmailAndPassword(email: email, password: password);
      await _syncWithBackend(cred.user);
      state = const AuthState(isLoading: false);
    } on FirebaseAuthException catch (e) {
      state = AuthState(error: e.message ?? e.code, isLoading: false);
    } catch (e) {
      state = AuthState(error: e.toString(), isLoading: false);
    }
  }

  Future<void> register(String email, String password) async {
    state = const AuthState(isLoading: true);
    try {
      final cred = await _auth.createUserWithEmailAndPassword(email: email, password: password);
      await _syncWithBackend(cred.user);
      state = const AuthState(isLoading: false);
    } on FirebaseAuthException catch (e) {
      state = AuthState(error: e.message ?? e.code, isLoading: false);
    } catch (e) {
      state = AuthState(error: e.toString(), isLoading: false);
    }
  }

  Future<void> loginWithGoogle() async {
    state = const AuthState(isLoading: true);
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        state = const AuthState(isLoading: false);
        return;
      }
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );
      final cred = await _auth.signInWithCredential(credential);
      await _syncWithBackend(cred.user);
      state = const AuthState(isLoading: false);
    } on FirebaseAuthException catch (e) {
      state = AuthState(error: e.message ?? e.code, isLoading: false);
    } catch (e) {
      state = AuthState(error: e.toString(), isLoading: false);
    }
  }

  Future<void> forgotPassword(String email) async {
    state = const AuthState(isLoading: true);
    try {
      await _auth.sendPasswordResetEmail(email: email);
      state = const AuthState(isLoading: false);
    } on FirebaseAuthException catch (e) {
      state = AuthState(error: e.message ?? e.code, isLoading: false);
    } catch (e) {
      state = AuthState(error: e.toString(), isLoading: false);
    }
  }

  Future<void> logout() async {
    await _googleSignIn.signOut();
    await _auth.signOut();
  }

  Future<void> _syncWithBackend(User? user) async {
    if (user == null) return;
    try {
      await dioClient.post('/users/sync');
    } catch (e) {
      debugPrint('Backend user sync failed: $e');
    }
  }
}


