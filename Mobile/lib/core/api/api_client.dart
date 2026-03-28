import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../config/env.dart';

final Dio dioClient = _setupDio();

Dio _setupDio() {
  final dio = Dio(
    BaseOptions(
      baseUrl: Env.apiBaseUrl,
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
      contentType: 'application/json',
    ),
  );

  dio.interceptors.add(
    InterceptorsWrapper(
      onRequest: (options, handler) async {
        // Automatically inject Firebase ID token if user is logged in
        final user = FirebaseAuth.instance.currentUser;
        if (user != null) {
          try {
            final idToken = await user.getIdToken(false);
            if (idToken != null) {
              options.headers['Authorization'] = 'Bearer \$idToken';
            }
          } catch (e) {
            // Ignore token fetch errors here
          }
        }
        return handler.next(options);
      },
      onResponse: (response, handler) {
        return handler.next(response);
      },
      onError: (DioException e, handler) {
        // Global error logging
        return handler.next(e);
      },
    ),
  );

  return dio;
}
