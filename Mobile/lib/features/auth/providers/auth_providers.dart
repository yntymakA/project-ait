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
  // NOTE: If testing on web/iOS, this might require explicit clientId configuration from your Backend.
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
        state = const AuthState(isLoading: false); // User cancelled
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

  Future<void> logout() async {
    await _googleSignIn.signOut();
    await _auth.signOut();
  }

  // Synchronize the logged-in Firebase User with the Custom FastAPI Backend
  Future<void> _syncWithBackend(User? user) async {
    if (user == null) return;
    try {
      // The Dio AuthInterceptor automatically attaches the \`Authorization: Bearer <ID_TOKEN>\` header.
      // So this request inherently passes the Firebase validity check on the backend!
      await dioClient.post('/users/sync');
    } catch (e) {
      // If the backend fails to sync, it might log a DioException.
      // We print it here, but typically you might want to sign them back out if sync is mandatory.
      print('Backend user sync failed: \$e');
      // For strict domains: throw Exception('Failed to synchronize user account');
    }
  }
}
