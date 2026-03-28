import 'package:dio/dio.dart';
import 'env.dart';
import '../auth/auth_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final dioProvider = Provider<Dio>((ref) {
  final dio = Dio(BaseOptions(
    baseUrl: Env.apiBaseUrl,
    connectTimeout: const Duration(seconds: 10),
    receiveTimeout: const Duration(seconds: 10),
    headers: {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    },
  ));

  // Add Auth interceptor
  dio.interceptors.add(AuthInterceptor(ref));
  
  // Add Logging interceptor
  dio.interceptors.add(LogInterceptor(
    requestBody: true,
    responseBody: true,
    logPrint: (obj) => print('DioLog: $obj'),
  ));

  return dio;
});

class AuthInterceptor extends Interceptor {
  final Ref ref;

  AuthInterceptor(this.ref);

  @override
  Future<void> onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    // We will get the token from FirebaseAuth instance exposed via providers.
    final token = await ref.read(firebaseTokenProvider.future);
    
    if (token != null) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    
    // Pass preferred language logic later for i18n
    // options.headers['Accept-Language'] = 'en';

    handler.next(options);
  }
}
