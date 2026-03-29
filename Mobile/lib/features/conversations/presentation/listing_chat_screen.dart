import 'package:cached_network_image/cached_network_image.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../listings/data/models/listing.dart';
import '../../listings/providers/listing_providers.dart';
import '../../profile/providers/me_profile_provider.dart';
import '../data/models/chat_models.dart';
import '../providers/conversation_providers.dart';

class ListingChatScreen extends ConsumerStatefulWidget {
  final int listingId;
  final Listing? listing;

  const ListingChatScreen({
    super.key,
    required this.listingId,
    this.listing,
  });

  @override
  ConsumerState<ListingChatScreen> createState() => _ListingChatScreenState();
}

class _ListingChatScreenState extends ConsumerState<ListingChatScreen> {
  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  int? _conversationId;
  List<ChatMessage> _messages = [];
  bool _loading = true;
  bool _sending = false;
  String? _error;
  bool _bootstrapped = false;
  bool _scheduledBootstrap = false;

  @override
  void dispose() {
    _textController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  String _formatTime(DateTime t) {
    return DateFormat.Hm().format(t.toLocal());
  }

  Future<void> _bootstrap(Listing listing) async {
    if (_bootstrapped) return;
    _bootstrapped = true;
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final repo = ref.read(conversationRepositoryProvider);
      final conv = await repo.startConversation(
        listingId: listing.id,
        recipientId: listing.ownerId,
      );
      final msgs = await repo.getMessages(conv.id);
      if (!mounted) return;
      setState(() {
        _conversationId = conv.id;
        _messages = msgs;
        _loading = false;
      });
      _scrollToEnd();
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = _formatError(e);
        _loading = false;
        _bootstrapped = false;
      });
    }
  }

  String _formatError(Object e) {
    if (e is DioException) {
      final d = e.response?.data;
      if (d is Map && d['detail'] != null) return d['detail'].toString();
      return e.message ?? 'Ошибка сети';
    }
    return e.toString();
  }

  void _scrollToEnd() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scrollController.hasClients) return;
      _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
    });
  }

  Future<void> _send() async {
    final convId = _conversationId;
    final me = await ref.read(currentMeProvider.future);
    if (convId == null || me == null) return;
    final raw = _textController.text.trim();
    if (raw.isEmpty || _sending) return;

    setState(() => _sending = true);
    try {
      final repo = ref.read(conversationRepositoryProvider);
      final msg = await repo.sendText(conversationId: convId, text: raw);
      if (!mounted) return;
      _textController.clear();
      setState(() {
        _messages = [..._messages, msg];
        _sending = false;
      });
      _scrollToEnd();
    } catch (e) {
      if (!mounted) return;
      setState(() => _sending = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_formatError(e)),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final listingAsync = widget.listing != null
        ? AsyncValue<Listing>.data(widget.listing!)
        : ref.watch(listingDetailProvider(widget.listingId));
    final meAsync = ref.watch(currentMeProvider);

    return listingAsync.when(
      loading: () => const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (e, _) => Scaffold(
        appBar: AppBar(title: const Text('Чат')),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Text('Не удалось загрузить объявление: $e'),
          ),
        ),
      ),
      data: (listing) {
        return meAsync.when(
          loading: () => const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          ),
          error: (e, _) => Scaffold(
            appBar: AppBar(title: const Text('Чат')),
            body: Center(child: Text('Профиль: $e')),
          ),
          data: (me) {
            if (me == null) {
              return Scaffold(
                appBar: AppBar(title: const Text('Чат')),
                body: const Center(child: Text('Войдите, чтобы писать в чате')),
              );
            }
            if (me.id == listing.ownerId) {
              return Scaffold(
                appBar: AppBar(title: const Text('Чат')),
                body: const Center(
                  child: Padding(
                    padding: EdgeInsets.all(AppSpacing.md),
                    child: Text('Это ваше объявление — чат с продавцом недоступен.'),
                  ),
                ),
              );
            }
            if (!_scheduledBootstrap) {
              _scheduledBootstrap = true;
              WidgetsBinding.instance.addPostFrameCallback((_) {
                _bootstrap(listing);
              });
            }
            return _buildScaffold(context, listing, me.id);
          },
        );
      },
    );
  }

  Widget _buildScaffold(BuildContext context, Listing listing, int myUserId) {
    final images = List<ListingImage>.from(listing.images)
      ..sort((a, b) => a.orderIndex.compareTo(b.orderIndex));
    final thumb = images.isNotEmpty ? images.first.fileUrl : null;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        surfaceTintColor: Colors.transparent,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Чат', style: AppTextStyles.titleMedium),
            Text(
              listing.title,
              style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          _ListingPinnedCard(
            listing: listing,
            imageUrl: thumb,
            onOpenListing: () => context.push('/listing/${listing.id}', extra: listing),
          ),
          const Divider(height: 1),
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : _error != null
                    ? Center(
                        child: Padding(
                          padding: const EdgeInsets.all(AppSpacing.md),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(_error!, textAlign: TextAlign.center),
                              const SizedBox(height: AppSpacing.md),
                              FilledButton(
                                onPressed: () {
                                  setState(() {
                                    _bootstrapped = false;
                                    _error = null;
                                  });
                                  _bootstrap(listing);
                                },
                                child: const Text('Повторить'),
                              ),
                            ],
                          ),
                        ),
                      )
                    : ListView.builder(
                        controller: _scrollController,
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.md,
                          vertical: AppSpacing.sm,
                        ),
                        itemCount: _messages.length,
                        itemBuilder: (context, index) {
                          final m = _messages[index];
                          final mine = m.senderId == myUserId;
                          return _MessageBubble(
                            text: m.textBody ?? '',
                            time: _formatTime(m.sentAt),
                            isMine: mine,
                          );
                        },
                      ),
          ),
          SafeArea(
            top: false,
            child: Container(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.md,
                AppSpacing.sm,
                AppSpacing.md,
                AppSpacing.md,
              ),
              decoration: BoxDecoration(
                color: AppColors.surface,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.blackWithOpacity(0.06),
                    blurRadius: 8,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Expanded(
                    child: TextField(
                      controller: _textController,
                      minLines: 1,
                      maxLines: 5,
                      textCapitalization: TextCapitalization.sentences,
                      decoration: InputDecoration(
                        hintText: 'Сообщение…',
                        filled: true,
                        fillColor: AppColors.surfaceVariant,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(AppSpacing.md),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.md,
                          vertical: AppSpacing.sm,
                        ),
                      ),
                      onSubmitted: (_) => _send(),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  IconButton.filled(
                    onPressed: _loading || _conversationId == null || _sending ? null : _send,
                    icon: _sending
                        ? const SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.send_rounded),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ListingPinnedCard extends StatelessWidget {
  final Listing listing;
  final String? imageUrl;
  final VoidCallback onOpenListing;

  const _ListingPinnedCard({
    required this.listing,
    required this.imageUrl,
    required this.onOpenListing,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surface,
      child: InkWell(
        onTap: onOpenListing,
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: AppSpacing.roundedSm,
                child: SizedBox(
                  width: 72,
                  height: 72,
                  child: imageUrl != null
                      ? CachedNetworkImage(
                          imageUrl: imageUrl!,
                          fit: BoxFit.cover,
                          placeholder: (_, _) => Container(color: AppColors.grey200),
                          errorWidget: (_, _, _) => Container(
                            color: AppColors.grey200,
                            child: const Icon(Icons.image_not_supported_outlined),
                          ),
                        )
                      : Container(
                          color: AppColors.grey200,
                          child: const Icon(Icons.image_outlined, color: AppColors.grey400),
                        ),
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'По объявлению',
                      style: AppTextStyles.labelSmall.copyWith(
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      listing.title,
                      style: AppTextStyles.titleSmall,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '\$${listing.price.toInt()} ${listing.currency} · ${listing.city}',
                      style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Открыть объявление',
                      style: AppTextStyles.labelSmall.copyWith(color: AppColors.primary),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, color: AppColors.grey400),
            ],
          ),
        ),
      ),
    );
  }
}

class _MessageBubble extends StatelessWidget {
  final String text;
  final String time;
  final bool isMine;

  const _MessageBubble({
    required this.text,
    required this.time,
    required this.isMine,
  });

  @override
  Widget build(BuildContext context) {
    final bg = isMine ? AppColors.primary : AppColors.surfaceVariant;
    final fg = isMine ? AppColors.textOnPrimary : AppColors.textPrimary;
    final align = isMine ? Alignment.centerRight : Alignment.centerLeft;

    return Align(
      alignment: align,
      child: Container(
        margin: const EdgeInsets.only(bottom: AppSpacing.sm),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.sizeOf(context).width * 0.82,
        ),
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(AppSpacing.md),
            topRight: const Radius.circular(AppSpacing.md),
            bottomLeft: Radius.circular(isMine ? AppSpacing.md : 4),
            bottomRight: Radius.circular(isMine ? 4 : AppSpacing.md),
          ),
          boxShadow: isMine
              ? null
              : [
                  BoxShadow(
                    color: AppColors.blackWithOpacity(0.04),
                    blurRadius: 4,
                    offset: const Offset(0, 1),
                  ),
                ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: Text(text, style: AppTextStyles.bodyMedium.copyWith(color: fg, height: 1.35)),
            ),
            const SizedBox(height: 4),
            Text(
              time,
              style: AppTextStyles.labelSmall.copyWith(
                color: isMine
                    ? AppColors.textOnPrimary.withValues(alpha: 0.85)
                    : AppColors.grey500,
                fontSize: 11,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
