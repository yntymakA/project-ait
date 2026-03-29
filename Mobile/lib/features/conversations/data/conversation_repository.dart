import 'package:dio/dio.dart';

import '../../../core/api/api_client.dart';
import 'models/chat_models.dart';

class ConversationRepository {
  final Dio _dio;

  ConversationRepository({Dio? dio}) : _dio = dio ?? dioClient;

  Future<ConversationDto> startConversation({
    required int listingId,
    required int recipientId,
  }) async {
    final res = await _dio.post<Map<String, dynamic>>(
      '/conversations',
      data: {
        'listing_id': listingId,
        'recipient_id': recipientId,
      },
    );
    return ConversationDto.fromJson(res.data!);
  }

  Future<List<ChatMessage>> getMessages(int conversationId) async {
    final res = await _dio.get<Map<String, dynamic>>(
      '/conversations/$conversationId/messages',
      queryParameters: {'limit': 100, 'offset': 0},
    );
    final data = res.data!;
    final items = data['items'] as List<dynamic>? ?? [];
    return items
        .map((e) => ChatMessage.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<ChatMessage> sendText({
    required int conversationId,
    required String text,
  }) async {
    final res = await _dio.post<Map<String, dynamic>>(
      '/conversations/$conversationId/messages',
      data: {'text_body': text.trim()},
    );
    return ChatMessage.fromJson(res.data!);
  }
}
