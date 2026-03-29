import 'package:dio/dio.dart';

import '../../../core/api/api_client.dart';

class ReportRepository {
  final Dio _dio;

  ReportRepository({Dio? dio}) : _dio = dio ?? dioClient;

  /// Жалоба на пользователя (продавца). `reason_code` фиксированный, текст — в `reason_text`.
  Future<void> submitUserReport({
    required int targetUserId,
    required String reasonText,
  }) async {
    await _dio.post<Map<String, dynamic>>(
      '/reports',
      data: {
        'target_type': 'user',
        'target_id': targetUserId,
        'reason_code': 'seller',
        'reason_text': reasonText,
      },
    );
  }
}
