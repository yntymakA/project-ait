import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/l10n/generated/app_localizations.dart';
import '../../../../core/widgets/status_widgets.dart';
import '../../listings/presentation/widgets/listing_card.dart';
import '../providers/favorite_provider.dart';

class FavoritesScreen extends ConsumerStatefulWidget {
  const FavoritesScreen({super.key});

  @override
  ConsumerState<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends ConsumerState<FavoritesScreen> {
  int _currentPage = 0;
  final int _pageSize = 20;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final favState = ref.watch(favoritesProvider(FavoritePaginationArgs(offset: _currentPage * _pageSize, limit: _pageSize)));

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.favoritesTab),
      ),
      body: favState.when(
        loading: () => const LoadingIndicator(),
        error: (e, st) => AppErrorWidget(
          error: e,
          onRetry: () => ref.refresh(favoritesProvider(FavoritePaginationArgs(offset: 0, limit: _pageSize))),
        ),
        data: (paginatedData) {
          if (paginatedData.items.isEmpty) {
            return const EmptyStateWidget(message: 'No favorites yet. Start saving items you like!');
          }
          
          return RefreshIndicator(
            onRefresh: () async {
              setState(() => _currentPage = 0);
              ref.refresh(favoritesProvider(FavoritePaginationArgs(offset: 0, limit: _pageSize)));
            },
            child: GridView.builder(
              padding: const EdgeInsets.all(12),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.75,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
              ),
              itemCount: paginatedData.items.length,
              itemBuilder: (context, index) {
                final listing = paginatedData.items[index];
                return ListingCard(
                  listing: listing,
                  onTap: () {
                    context.push('/listing', extra: listing);
                  },
                );
              },
            ),
          );
        },
      ),
    );
  }
}
