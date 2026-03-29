import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/conversation_repository.dart';
import '../data/models/chat_models.dart';

final conversationRepositoryProvider = Provider<ConversationRepository>((ref) {
  return ConversationRepository();
});

final conversationsListProvider =
    FutureProvider.autoDispose<List<ConversationListItem>>((ref) async {
  final repo = ref.watch(conversationRepositoryProvider);
  final page = await repo.listConversations(limit: 50, offset: 0);
  return page.items;
});
