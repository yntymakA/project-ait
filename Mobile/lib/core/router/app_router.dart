import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'main_shell.dart';
import '../../features/listings/presentation/feed_screen.dart';
import '../../features/favorites/presentation/favorites_screen.dart';
import '../../features/create/presentation/create_screen.dart';
import '../../features/conversations/presentation/inbox_screen.dart';
import '../../features/profile/presentation/profile_screen.dart';
import '../../features/auth/presentation/login_screen.dart';
import '../../features/auth/presentation/register_screen.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../auth/auth_provider.dart';

final routerProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authStateProvider);

  // We scope the GlobalKeys to the router instance so that if the router is rebuilt
  // (e.g., on login/logout), new keys are generated, avoiding the "Multiple widgets used the same GlobalKey" error.
  final rootNavigatorKey = GlobalKey<NavigatorState>();
  final shellNavigatorHomeKey = GlobalKey<NavigatorState>(debugLabel: 'HomeTab');
  final shellNavigatorFavoritesKey = GlobalKey<NavigatorState>(debugLabel: 'FavTab');
  final shellNavigatorCreateKey = GlobalKey<NavigatorState>(debugLabel: 'CreateTab');
  final shellNavigatorChatsKey = GlobalKey<NavigatorState>(debugLabel: 'ChatsTab');
  final shellNavigatorProfileKey = GlobalKey<NavigatorState>(debugLabel: 'ProfileTab');

  return GoRouter(
    navigatorKey: rootNavigatorKey,
    initialLocation: '/feed',
    redirect: (context, state) {
      final loggedIn = authState.value != null;
      final loggingIn = state.uri.toString() == '/login' || state.uri.toString() == '/register';

      final requiresAuth = state.uri.toString().startsWith('/inbox') ||
                           state.uri.toString().startsWith('/create') ||
                           state.uri.toString().startsWith('/favorites');

      if (requiresAuth && !loggedIn) {
        return '/login';
      }

      if (loggedIn && loggingIn) {
        return '/feed';
      }

      return null;
    },
    routes: [
    // Auth Routes
    GoRoute(
      path: '/login',
      builder: (context, state) => const LoginScreen(),
    ),
    GoRoute(
      path: '/register',
      builder: (context, state) => const RegisterScreen(),
    ),
    
    // Main App Shell
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) {
        return MainShell(navigationShell: navigationShell);
      },
      branches: [
        // Tab 1: Home Feed
        StatefulShellBranch(
          navigatorKey: shellNavigatorHomeKey,
          routes: [
            GoRoute(
              path: '/feed',
              builder: (context, state) => const FeedScreen(),
            ),
          ],
        ),
        // Tab 2: Favorites
        StatefulShellBranch(
          navigatorKey: shellNavigatorFavoritesKey,
          routes: [
            GoRoute(
              path: '/favorites',
              builder: (context, state) => const FavoritesScreen(),
            ),
          ],
        ),
        // Tab 3: Create
        StatefulShellBranch(
          navigatorKey: shellNavigatorCreateKey,
          routes: [
            GoRoute(
              path: '/create',
              builder: (context, state) => const CreateScreen(),
            ),
          ],
        ),
        // Tab 4: Chats
        StatefulShellBranch(
          navigatorKey: shellNavigatorChatsKey,
          routes: [
            GoRoute(
              path: '/inbox',
              builder: (context, state) => const InboxScreen(),
            ),
          ],
        ),
        // Tab 5: Profile
        StatefulShellBranch(
          navigatorKey: shellNavigatorProfileKey,
          routes: [
            GoRoute(
              path: '/profile',
              builder: (context, state) => const ProfileScreen(),
            ),
          ],
        ),
      ],
    ),
  ],
);
});
