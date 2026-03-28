import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/models/notification.dart';
import '../data/repositories/notification_repository.dart';

final notificationRepositoryProvider = Provider<NotificationRepository>((ref) {
  return NotificationRepository();
});

class NotificationState {
  final List<NotificationModel> notifications;
  final int unreadCount;
  final int total;
  final bool isLoadingMore;
  final bool hasMore;

  NotificationState({
    required this.notifications,
    required this.unreadCount,
    required this.total,
    this.isLoadingMore = false,
    this.hasMore = true,
  });

  NotificationState copyWith({
    List<NotificationModel>? notifications,
    int? unreadCount,
    int? total,
    bool? isLoadingMore,
    bool? hasMore,
  }) {
    return NotificationState(
      notifications: notifications ?? this.notifications,
      unreadCount: unreadCount ?? this.unreadCount,
      total: total ?? this.total,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      hasMore: hasMore ?? this.hasMore,
    );
  }
}

class NotificationNotifier extends AsyncNotifier<NotificationState> {
  static const int _limit = 20;

  NotificationRepository get _repository => ref.read(notificationRepositoryProvider);

  @override
  Future<NotificationState> build() async {
    return _fetchInitial();
  }

  Future<NotificationState> _fetchInitial() async {
    final data = await _repository.getNotifications(limit: _limit, offset: 0);
    final items = data['items'] as List<NotificationModel>;
    
    return NotificationState(
      notifications: items,
      unreadCount: data['unread_count'] as int,
      total: data['total'] as int,
      hasMore: items.length < (data['total'] as int),
    );
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _fetchInitial());
  }

  Future<void> loadMore() async {
    final currentState = state.value;
    if (currentState == null || currentState.isLoadingMore || !currentState.hasMore) return;

    state = AsyncValue.data(currentState.copyWith(isLoadingMore: true));

    try {
      final data = await _repository.getNotifications(
        limit: _limit,
        offset: currentState.notifications.length,
      );
      final newItems = data['items'] as List<NotificationModel>;
      
      state = AsyncValue.data(currentState.copyWith(
        notifications: [...currentState.notifications, ...newItems],
        unreadCount: data['unread_count'] as int,
        total: data['total'] as int,
        isLoadingMore: false,
        hasMore: (currentState.notifications.length + newItems.length) < (data['total'] as int),
      ));
    } catch (e, st) {
      state = AsyncValue.data(currentState.copyWith(isLoadingMore: false));
    }
  }

  Future<void> markAsRead(int id) async {
    final currentState = state.value;
    if (currentState == null) return;

    try {
      final updated = await _repository.markAsRead(id);
      
      final newList = currentState.notifications.map((n) {
        return n.id == id ? updated : n;
      }).toList();

      state = AsyncValue.data(currentState.copyWith(
        notifications: newList,
        unreadCount: currentState.unreadCount > 0 ? currentState.unreadCount - 1 : 0,
      ));
    } catch (e) {
      // Log/ignore
    }
  }

  Future<void> markAllAsRead() async {
    final currentState = state.value;
    if (currentState == null) return;

    try {
      await _repository.markAllAsRead();
      final newList = currentState.notifications.map((n) {
        return n.copyWith(isRead: true);
      }).toList();

      state = AsyncValue.data(currentState.copyWith(
        notifications: newList,
        unreadCount: 0,
      ));
    } catch (e) {
      // Log/ignore
    }
  }
}

final notificationProvider = AsyncNotifierProvider<NotificationNotifier, NotificationState>(
  NotificationNotifier.new,
);
