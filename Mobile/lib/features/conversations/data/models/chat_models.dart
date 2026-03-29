class ConversationDto {
  final int id;
  final int listingId;
  final int participantAId;
  final int participantBId;

  const ConversationDto({
    required this.id,
    required this.listingId,
    required this.participantAId,
    required this.participantBId,
  });

  factory ConversationDto.fromJson(Map<String, dynamic> json) {
    return ConversationDto(
      id: (json['id'] as num).toInt(),
      listingId: (json['listing_id'] as num).toInt(),
      participantAId: (json['participant_a_id'] as num).toInt(),
      participantBId: (json['participant_b_id'] as num).toInt(),
    );
  }
}

class ChatMessage {
  final int id;
  final int conversationId;
  final int senderId;
  final String? textBody;
  final DateTime sentAt;

  const ChatMessage({
    required this.id,
    required this.conversationId,
    required this.senderId,
    required this.textBody,
    required this.sentAt,
  });

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      id: (json['id'] as num).toInt(),
      conversationId: (json['conversation_id'] as num).toInt(),
      senderId: (json['sender_id'] as num).toInt(),
      textBody: json['text_body'] as String?,
      sentAt: DateTime.parse(json['sent_at'] as String),
    );
  }
}
