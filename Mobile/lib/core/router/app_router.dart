import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'main_shell.dart';
import '../../features/listings/presentation/feed_screen.dart';
import '../../features/listings/presentation/listing_detail_screen.dart';
import '../../features/conversations/presentation/listing_chat_screen.dart';
import '../../features/listings/data/models/listing.dart';
import '../../features/favorites/presentation/favorites_screen.dart';
import '../../features/create/presentation/create_screen.dart';
import '../../features/conversations/presentation/inbox_screen.dart';
import '../../features/profile/presentation/profile_screen.dart';
import '../../features/listings/presentation/my_listings_screen.dart';
import '../../features/listings/presentation/edit_listing_screen.dart';
import '../../features/profile/presentation/seller_profile_screen.dart';
import '../../features/auth/presentation/login_screen.dart';
import '../../features/auth/presentation/register_screen.dart';
import '../../features/auth/presentation/forgot_password_screen.dart';
import '../../features/notifications/presentation/notification_list_screen.dart';
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

      final path = state.uri.path;
      final isListingChat = path.startsWith('/listing/') && path.endsWith('/chat');
      final requiresAuth = state.uri.toString().startsWith('/inbox') ||
                           state.uri.toString().startsWith('/create') ||
                           state.uri.toString().startsWith('/favorites') ||
                           state.uri.toString().startsWith('/my-listings') ||
                           state.uri.toString().startsWith('/edit-listing') ||
                           isListingChat;

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
    GoRoute(
      path: '/forgot-password',
      builder: (context, state) => const ForgotPasswordScreen(),
    ),
    
    // Listing chat (more specific than /listing/:id)
    GoRoute(
      path: '/listing/:id/chat',
      parentNavigatorKey: rootNavigatorKey,
      builder: (context, state) {
        final idStr = state.pathParameters['id']!;
        final id = int.tryParse(idStr) ?? 0;
        final listing = state.extra as Listing?;
        final convParam = state.uri.queryParameters['conversationId'];
        final initialConversationId =
            convParam != null ? int.tryParse(convParam) : null;
        return ListingChatScreen(
          listingId: id,
          listing: listing,
          initialConversationId: initialConversationId,
        );
      },
    ),
    // Listing Details (Root level to hide bottom nav)
    GoRoute(
      path: '/listing/:id',
      parentNavigatorKey: rootNavigatorKey,
      builder: (context, state) {
        final idStr = state.pathParameters['id']!;
        final id = int.tryParse(idStr) ?? 0;
        final listing = state.extra as Listing?;
        return ListingDetailScreen(listingId: id, listing: listing);
      },
    ),
    GoRoute(
      path: '/users/:userId',
      parentNavigatorKey: rootNavigatorKey,
      builder: (context, state) {
        final idStr = state.pathParameters['userId']!;
        final id = int.tryParse(idStr) ?? 0;
        return SellerProfileScreen(userId: id);
      },
    ),
    GoRoute(
      path: '/my-listings',
      parentNavigatorKey: rootNavigatorKey,
      builder: (context, state) => const MyListingsScreen(),
    ),
    GoRoute(
      path: '/edit-listing/:id',
      parentNavigatorKey: rootNavigatorKey,
      builder: (context, state) {
        final idStr = state.pathParameters['id']!;
        final id = int.tryParse(idStr) ?? 0;
        return EditListingScreen(listingId: id);
      },
    ),
    
    // Notifications Screen
    GoRoute(
      path: '/notifications',
      parentNavigatorKey: rootNavigatorKey,
      builder: (context, state) => const NotificationListScreen(),
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
