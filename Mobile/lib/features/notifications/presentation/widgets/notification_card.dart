import 'package:flutter/material.dart';
import '../../data/models/notification.dart';

class NotificationCard extends StatelessWidget {
  final NotificationModel notification;
  final VoidCallback onTap;

  const NotificationCard({
    super.key,
    required this.notification,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isUnread = !notification.isRead;
    final info = _resolveInfo(notification);

    return InkWell(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: isUnread
              ? theme.colorScheme.primaryContainer.withOpacity(0.15)
              : Colors.transparent,
          border: Border(
            left: BorderSide(
              color: isUnread
                  ? theme.colorScheme.primary
                  : Colors.transparent,
              width: 3,
            ),
          ),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Icon circle
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: info.iconBg.withOpacity(0.15),
                shape: BoxShape.circle,
              ),
              child: Icon(info.icon, color: info.iconBg, size: 22),
            ),
            const SizedBox(width: 12),
            // Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    info.title,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: isUnread ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    info.body,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurface.withOpacity(0.65),
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _timeAgo(notification.createdAt),
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: theme.colorScheme.onSurface.withOpacity(0.45),
                    ),
                  ),
                ],
              ),
            ),
            if (isUnread)
              Container(
                width: 8,
                height: 8,
                margin: const EdgeInsets.only(top: 4, left: 8),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary,
                  shape: BoxShape.circle,
                ),
              ),
          ],
        ),
      ),
    );
  }

  _NotifInfo _resolveInfo(NotificationModel n) {
    final message = n.payload?['message'] as String? ?? '';
    final listingTitle = n.payload?['title'] as String? ?? 'your listing';

    return switch (n.type) {
      NotificationType.listingApproved => _NotifInfo(
          icon: Icons.check_circle_rounded,
          iconBg: Colors.green,
          title: 'Listing Approved ✅',
          body: message.isNotEmpty
              ? message
              : '"$listingTitle" has been approved and is now live!',
        ),
      NotificationType.listingRejected => _NotifInfo(
          icon: Icons.cancel_rounded,
          iconBg: Colors.red,
          title: 'Listing Rejected ❌',
          body: message.isNotEmpty
              ? message
              : '"$listingTitle" was not approved. Please review and resubmit.',
        ),
      NotificationType.newMessage => _NotifInfo(
          icon: Icons.chat_bubble_rounded,
          iconBg: Colors.blue,
          title: 'New Message 💬',
          body: message.isNotEmpty ? message : 'You have a new message.',
        ),
      NotificationType.paymentSuccess => _NotifInfo(
          icon: Icons.payments_rounded,
          iconBg: Colors.teal,
          title: 'Payment Successful 💰',
          body: message.isNotEmpty ? message : 'Your payment was processed.',
        ),
      NotificationType.promotionActivated => _NotifInfo(
          icon: Icons.rocket_launch_rounded,
          iconBg: Colors.orange,
          title: 'Promotion Activated 🚀',
          body: message.isNotEmpty ? message : 'Your promotion is now active!',
        ),
      NotificationType.promotionExpired => _NotifInfo(
          icon: Icons.timer_off_rounded,
          iconBg: Colors.grey,
          title: 'Promotion Expired ⏰',
          body: message.isNotEmpty ? message : 'Your promotion has ended.',
        ),
    };
  }

  String _timeAgo(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inHours < 1) return '${diff.inMinutes}m ago';
    if (diff.inDays < 1) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    return '${dt.day}/${dt.month}/${dt.year}';
  }
}

class _NotifInfo {
  final IconData icon;
  final Color iconBg;
  final String title;
  final String body;

  const _NotifInfo({
    required this.icon,
    required this.iconBg,
    required this.title,
    required this.body,
  });
}
