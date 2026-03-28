import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/l10n/generated/app_localizations.dart';

class MainShell extends StatelessWidget {
  final Widget child;

  const MainShell({required this.child, super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    
    int getSelectedIndex(BuildContext context) {
      final String location = GoRouterState.of(context).uri.toString();
      if (location.startsWith('/search')) return 1;
      if (location.startsWith('/favorites')) return 2;
      if (location.startsWith('/inbox')) return 3;
      if (location.startsWith('/profile')) return 4;
      return 0;
    }

    void onItemTapped(int index, BuildContext context) {
      switch (index) {
        case 0:
          context.go('/');
          break;
        case 1:
          context.go('/search');
          break;
        case 2:
          context.go('/favorites');
          break;
        case 3:
          context.go('/inbox');
          break;
        case 4:
          context.go('/profile');
          break;
      }
    }

    return Scaffold(
      body: child,
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: getSelectedIndex(context),
        onTap: (idx) => onItemTapped(idx, context),
        items: [
          BottomNavigationBarItem(
            icon: const Icon(Icons.home_outlined),
            activeIcon: const Icon(Icons.home),
            label: l10n.feedTitle,
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.search),
            activeIcon: const Icon(Icons.search_rounded),
            label: l10n.searchTab,
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.favorite_border),
            activeIcon: const Icon(Icons.favorite),
            label: l10n.favoritesTab,
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.inbox_outlined),
            activeIcon: const Icon(Icons.inbox),
            label: l10n.inboxTab,
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.person_outline),
            activeIcon: const Icon(Icons.person),
            label: l10n.profileTab,
          ),
        ],
      ),
    );
  }
}
