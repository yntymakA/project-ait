import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../auth/auth_provider.dart';



import '../features/auth/presentation/login_screen.dart';
import '../features/auth/presentation/register_screen.dart';
import '../features/listings/presentation/feed_screen.dart';
import '../features/listings/presentation/listing_details_screen.dart';
import '../features/listings/presentation/my_listings_screen.dart';
import '../features/listings/presentation/create_listing_screen.dart';
import '../features/profile/presentation/profile_screen.dart';
import '../features/favorites/presentation/favorites_screen.dart';
import '../features/inbox/presentation/inbox_screen.dart';
import '../widgets/main_shell.dart';
import '../widgets/empty_tab_placeholder.dart';


final routerProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authStateProvider);

  return GoRouter(
    initialLocation: '/',
    redirect: (context, state) {
      // The auth logic
      final loggedIn = authState.value != null;
      final loggingIn = state.uri.toString() == '/login' || state.uri.toString() == '/register';

      // Example guard logic:
      // If going to an auth-required route and not logged in, redirect to login
      final requiresAuth = state.uri.toString().startsWith('/profile') || 
                           state.uri.toString().startsWith('/inbox') ||
                           state.uri.toString().startsWith('/favorites');

      if (requiresAuth && !loggedIn) {
        return '/login';
      }

      // If logged in and trying to go to login screen, redirect to home
      if (loggedIn && loggingIn) {
        return '/';
      }

      return null; // no redirect needed
    },
    routes: [
      ShellRoute(
        builder: (context, state, child) => MainShell(child: child),
        routes: [
          GoRoute(
            path: '/',
            builder: (context, state) => const FeedScreen(),
          ),
          GoRoute(
            path: '/search',
            builder: (context, state) => const EmptyTabPlaceholder(title: 'Search'),
          ),
          GoRoute(
            path: '/favorites',
            builder: (context, state) => const FavoritesScreen(),
          ),
          GoRoute(
            path: '/inbox',
            builder: (context, state) => const InboxScreen(),
          ),
          GoRoute(
            path: '/profile',
            builder: (context, state) => const ProfileScreen(),
          ),
        ],
      ),
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/register',
        builder: (context, state) => const RegisterScreen(),
      ),
      GoRoute(
        path: '/listing',
        builder: (context, state) {
          final listing = state.extra as Listing;
          return ListingDetailsScreen(listing: listing);
        },
      ),
      GoRoute(
        path: '/my-listings',
        builder: (context, state) => const MyListingsScreen(),
      ),
      GoRoute(
        path: '/create-listing',
        builder: (context, state) => const CreateListingScreen(),
      ),
    ],
  );
});
