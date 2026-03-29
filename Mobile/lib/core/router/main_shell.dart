import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../l10n/l10n.dart';

class MainShell extends StatelessWidget {
  final StatefulNavigationShell navigationShell;

  const MainShell({super.key, required this.navigationShell});

  @override
  Widget build(BuildContext context) {
    final titles = [
      context.l10n.tabHome,
      context.l10n.tabFavorites,
      context.l10n.tabCreate,
      context.l10n.tabChats,
      context.l10n.tabProfile,
    ];
    final isHomeTab = navigationShell.currentIndex == 0;
    final isCreateTab = navigationShell.currentIndex == 2;
    final currentTitle = titles[navigationShell.currentIndex];

    return Scaffold(
      appBar: isCreateTab
          ? null
          : AppBar(
              title: isHomeTab
                  ? Row(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Container(
                          width: 28,
                          height: 28,
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            Icons.apartment_rounded,
                            size: 18,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Property Hub',
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.w700,
                                    height: 1.1,
                                  ),
                            ),
                            Text(
                              'marketplace',
                              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                    letterSpacing: 0.3,
                                  ),
                            ),
                          ],
                        ),
                      ],
                    )
                  : Text(currentTitle),
              centerTitle: false,
            ),
      body: navigationShell,
      bottomNavigationBar: NavigationBar(
        selectedIndex: navigationShell.currentIndex,
        onDestinationSelected: (index) {
          navigationShell.goBranch(
            index,
            initialLocation: index == navigationShell.currentIndex,
          );
        },
        destinations: [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: context.l10n.tabHome,
          ),
          NavigationDestination(
            icon: Icon(Icons.favorite_outline),
            selectedIcon: Icon(Icons.favorite),
            label: context.l10n.tabFavorites,
          ),
          NavigationDestination(
            icon: Icon(Icons.add_circle_outline),
            selectedIcon: Icon(Icons.add_circle),
            label: context.l10n.tabCreate,
          ),
          NavigationDestination(
            icon: Icon(Icons.chat_bubble_outline),
            selectedIcon: Icon(Icons.chat_bubble),
            label: context.l10n.tabChats,
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person),
            label: context.l10n.tabProfile,
          ),
        ],
      ),
    );
  }
}
