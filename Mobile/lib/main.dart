import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'core/services/notification_service.dart';
import 'core/auth/auth_provider.dart';
import 'features/notifications/providers/notification_provider.dart';
import 'firebase_options.dart';

/// A single GlobalKey so NotificationService can navigate when the user
/// taps a push notification while the app is in the background / terminated.
final rootNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'root');

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (e) {
    debugPrint("Firebase not configured yet: $e");
  }

  // Initialize FCM listeners (permissions, foreground display, tap handling)
  await NotificationService().initialize(navigatorKey: rootNavigatorKey);

  runApp(const ProviderScope(child: MarketplaceApp()));
}

class MarketplaceApp extends ConsumerWidget {
  const MarketplaceApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);

    // Register the FCM device token whenever the user logs in
    ref.listen<AsyncValue<dynamic>>(authStateProvider, (previous, next) {
      final wasLoggedOut = previous?.value == null;
      final isNowLoggedIn = next.value != null;
      if (wasLoggedOut && isNowLoggedIn) {
        final repo = ref.read(notificationRepositoryProvider);
        NotificationService().registerDeviceToken(repo);
      }
    });

    return MaterialApp.router(
      title: 'AIT Marketplace',
      theme: AppTheme.light,
      routerConfig: router,
    );
  }
}


