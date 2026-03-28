import 'dart:async';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../../features/notifications/data/repositories/notification_repository.dart';

/// Single entry-point for all FCM + local notification logic.
///
/// Usage:
///   1. Call `NotificationService().initialize(navigatorKey)` once in main().
///   2. After login, call `NotificationService().registerDeviceToken(repo)`.
class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FirebaseMessaging _fcm = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotif =
      FlutterLocalNotificationsPlugin();

  /// Provide this key from main.dart so we can navigate on notification tap.
  GlobalKey<NavigatorState>? _navigatorKey;

  Future<void> initialize({GlobalKey<NavigatorState>? navigatorKey}) async {
    _navigatorKey = navigatorKey;

    // 1. Request permissions (iOS/Android 13+)
    final settings = await _fcm.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );
    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      debugPrint('NotificationService: permissions granted');
    }

    // 2. Setup local notifications for foreground display
    const androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings();
    await _localNotif.initialize(
      const InitializationSettings(android: androidSettings, iOS: iosSettings),
    );

    // 3. Foreground — show a heads-up notification
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      debugPrint('FCM foreground: ${message.notification?.title}');
      _showLocalNotification(message);
    });

    // 4. Background / terminated — user tapped the push notification
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      debugPrint('FCM tapped from background: ${message.notification?.title}');
      _navigateToNotifications();
    });

    // 5. Terminated state — app opened via notification
    final initial = await _fcm.getInitialMessage();
    if (initial != null) {
      // Slight delay so the navigator is mounted
      Future.delayed(const Duration(milliseconds: 500), _navigateToNotifications);
    }
  }

  /// Call this once the user is logged in to register the device for pushes.
  Future<void> registerDeviceToken(NotificationRepository repo) async {
    final token = await getToken();
    if (token == null) {
      debugPrint('NotificationService: no FCM token available');
      return;
    }
    try {
      await repo.saveDeviceToken(token);
      debugPrint('NotificationService: FCM token registered');
    } catch (e) {
      debugPrint('NotificationService: failed to register token – $e');
    }
  }

  Future<String?> getToken() async {
    try {
      return await _fcm.getToken();
    } catch (e) {
      debugPrint('Failed to get FCM token: $e');
      return null;
    }
  }

  void _navigateToNotifications() {
    _navigatorKey?.currentState?.pushNamed('/notifications');
  }

  void _showLocalNotification(RemoteMessage message) {
    final notification = message.notification;
    if (notification != null) {
      _localNotif.show(
        notification.hashCode,
        notification.title,
        notification.body,
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'high_importance_channel',
            'High Importance Notifications',
            importance: Importance.max,
            priority: Priority.high,
            icon: '@mipmap/ic_launcher',
          ),
          iOS: DarwinNotificationDetails(),
        ),
      );
    }
  }
}
