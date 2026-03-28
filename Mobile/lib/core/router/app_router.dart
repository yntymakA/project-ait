import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'main_shell.dart';
import '../../features/listings/presentation/feed_screen.dart';
import '../../features/search/presentation/search_screen.dart';
import '../../features/favorites/presentation/favorites_screen.dart';
import '../../features/conversations/presentation/inbox_screen.dart';
import '../../features/profile/presentation/profile_screen.dart';

final rootNavigatorKey = GlobalKey<NavigatorState>();
final shellNavigatorHomeKey = GlobalKey<NavigatorState>(debugLabel: 'HomeTab');
final shellNavigatorSearchKey = GlobalKey<NavigatorState>(debugLabel: 'SearchTab');
final shellNavigatorFavoritesKey = GlobalKey<NavigatorState>(debugLabel: 'FavTab');
final shellNavigatorInboxKey = GlobalKey<NavigatorState>(debugLabel: 'InboxTab');
final shellNavigatorProfileKey = GlobalKey<NavigatorState>(debugLabel: 'ProfileTab');

final appRouter = GoRouter(
  navigatorKey: rootNavigatorKey,
  initialLocation: '/feed',
  routes: [
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
        // Tab 2: Search
        StatefulShellBranch(
          navigatorKey: shellNavigatorSearchKey,
          routes: [
            GoRoute(
              path: '/search',
              builder: (context, state) => const SearchScreen(),
            ),
          ],
        ),
        // Tab 3: Favorites
        StatefulShellBranch(
          navigatorKey: shellNavigatorFavoritesKey,
          routes: [
            GoRoute(
              path: '/favorites',
              builder: (context, state) => const FavoritesScreen(),
            ),
          ],
        ),
        // Tab 4: Inbox
        StatefulShellBranch(
          navigatorKey: shellNavigatorInboxKey,
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
