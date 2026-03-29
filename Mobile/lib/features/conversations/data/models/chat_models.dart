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

/// Row from `GET /conversations` (ConversationListInfo).
class ConversationListItem {
  final int id;
  final int listingId;
  final String listingTitle;
  final int otherParticipantId;
  final String otherParticipantName;
  final String? lastMessageText;
  final DateTime? lastMessageAt;
  final int unreadCount;

  const ConversationListItem({
    required this.id,
    required this.listingId,
    required this.listingTitle,
    required this.otherParticipantId,
    required this.otherParticipantName,
    this.lastMessageText,
    this.lastMessageAt,
    this.unreadCount = 0,
  });

  factory ConversationListItem.fromJson(Map<String, dynamic> json) {
    return ConversationListItem(
      id: (json['id'] as num).toInt(),
      listingId: (json['listing_id'] as num).toInt(),
      listingTitle: json['listing_title'] as String? ?? '',
      otherParticipantId: (json['other_participant_id'] as num).toInt(),
      otherParticipantName: json['other_participant_name'] as String? ?? '',
      lastMessageText: json['last_message_text'] as String?,
      lastMessageAt: json['last_message_at'] != null
          ? DateTime.parse(json['last_message_at'] as String)
          : null,
      unreadCount: (json['unread_count'] as num?)?.toInt() ?? 0,
    );
  }
}

class ConversationListPage {
  final List<ConversationListItem> items;
  final int total;
  final int limit;
  final int offset;

  const ConversationListPage({
    required this.items,
    required this.total,
    required this.limit,
    required this.offset,
  });

  factory ConversationListPage.fromJson(Map<String, dynamic> json) {
    final raw = json['items'] as List<dynamic>? ?? [];
    return ConversationListPage(
      items: raw
          .map((e) => ConversationListItem.fromJson(e as Map<String, dynamic>))
          .toList(),
      total: (json['total'] as num?)?.toInt() ?? 0,
      limit: (json['limit'] as num?)?.toInt() ?? 0,
      offset: (json['offset'] as num?)?.toInt() ?? 0,
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
