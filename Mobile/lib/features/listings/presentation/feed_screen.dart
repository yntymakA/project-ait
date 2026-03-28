import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/listings_provider.dart';
import 'widgets/listing_card.dart';

class FeedScreen extends ConsumerStatefulWidget {
  const FeedScreen({super.key});

  @override
  ConsumerState<FeedScreen> createState() => _FeedScreenState();
}

class _FeedScreenState extends ConsumerState<FeedScreen> {
  // Simplified pagination state for Phase 2
  int _currentPage = 0;
  final int _pageSize = 20;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final feedState = ref.watch(feedProvider(FeedPaginationArgs(offset: _currentPage * _pageSize, limit: _pageSize)));

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.feedTitle),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () {
              // TODO: Open filter bottom sheet
            },
          )
        ],
      ),
      body: feedState.when(
        loading: () => const LoadingIndicator(),
        error: (e, st) => AppErrorWidget(
          error: e,
          onRetry: () => ref.refresh(feedProvider(FeedPaginationArgs(offset: 0, limit: _pageSize))),
        ),
        data: (paginatedData) {
          if (paginatedData.items.isEmpty) {
            return EmptyStateWidget(message: l10n.emptyState);
          }
          
          return RefreshIndicator(
            onRefresh: () async {
              setState(() => _currentPage = 0);
              ref.refresh(feedProvider(FeedPaginationArgs(offset: 0, limit: _pageSize)));
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
