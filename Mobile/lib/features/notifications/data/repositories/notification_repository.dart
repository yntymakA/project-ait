import 'package:dio/dio.dart';
import '../../../../core/api/api_client.dart';
import '../models/notification.dart';

class NotificationRepository {
  final Dio _dio;

  NotificationRepository({Dio? dio}) : _dio = dio ?? dioClient;

  Future<Map<String, dynamic>> getNotifications({
    int limit = 20,
    int offset = 0,
  }) async {
    final response = await _dio.get(
      '/notifications',
      queryParameters: {
        'limit': limit,
        'offset': offset,
      },
    );
    
    final data = response.data as Map<String, dynamic>;
    final items = (data['items'] as List)
        .map((json) => NotificationModel.fromJson(json as Map<String, dynamic>))
        .toList();
    
    return {
      'items': items,
      'unread_count': data['unread_count'] as int,
      'total': data['total'] as int,
    };
  }

  Future<NotificationModel> markAsRead(int notificationId) async {
    final response = await _dio.patch('/notifications/$notificationId/read');
    return NotificationModel.fromJson(response.data as Map<String, dynamic>);
  }

  Future<void> markAllAsRead() async {
    await _dio.patch('/notifications/read-all');
  }

  Future<void> saveDeviceToken(String fcmToken) async {
    await _dio.post(
      '/notifications/device-token',
      data: {'fcm_token': fcmToken},
    );
  }
}
