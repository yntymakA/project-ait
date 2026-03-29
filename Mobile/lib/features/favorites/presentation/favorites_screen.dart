import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/favorite_providers.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/listing_card.dart';
import '../../../core/widgets/app_button.dart';

class FavoritesScreen extends ConsumerStatefulWidget {
  const FavoritesScreen({super.key});

  @override
  ConsumerState<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends ConsumerState<FavoritesScreen> {
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    // Fetch initial favorites if needed, but provider already does this on build
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (!mounted) return;
    
    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.position.pixels;
    if (currentScroll >= (maxScroll * 0.8)) {
      ref.read(favoritesListProvider.notifier).loadMore();
    }
  }

  @override
  Widget build(BuildContext context) {
    final favoritesStateAsync = ref.watch(favoritesListProvider);
    final favoriteIds = ref.watch(favoriteIdsProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: RefreshIndicator(
        color: AppColors.primary,
        onRefresh: () => ref.read(favoritesListProvider.notifier).refresh(),
        child: favoritesStateAsync.when(
          data: (state) {
            final listings = state.listings;

            if (listings.isEmpty) {
              return _buildEmptyState();
            }

            return CustomScrollView(
              controller: _scrollController,
              slivers: [
                SliverPadding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.md,
                    vertical: AppSpacing.md,
                  ),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        if (index == listings.length) {
                          if (state.isLoadingMore) {
                            return const Padding(
                              padding: EdgeInsets.symmetric(vertical: AppSpacing.xl),
                              child: Center(child: CircularProgressIndicator()),
                            );
                          }
                          return const SizedBox.shrink();
                        }

                        final listing = listings[index];
                        final primaryImage = listing.images.isNotEmpty 
                            ? listing.images.firstWhere((img) => img.isPrimary, orElse: () => listing.images.first).fileUrl 
                            : null;

                        return Padding(
                          padding: const EdgeInsets.only(bottom: AppSpacing.md),
                          child: ListingCard(
                            title: listing.title,
                            price: '${listing.price} ${listing.currency}',
                            city: listing.city,
                            imageUrl: primaryImage,
                            isPromoted: listing.promotionStatus == 'ACTIVE',
                            isFavorited: favoriteIds.contains(listing.id),
                            onFavoriteTap: () {
                              ref.read(favoriteIdsProvider.notifier).toggleFavorite(listing.id);
                            },
                            onTap: () {
                              context.push('/listing/${listing.id}', extra: listing);
                            },
                          ),
                        );
                      },
                      childCount: listings.length + 1,
                    ),
                  ),
                ),
              ],
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, stack) => _buildErrorState(error),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.favorite_border_rounded,
            size: 80,
            color: AppColors.grey300,
          ),
          const SizedBox(height: AppSpacing.lg),
          Text(
            'No favorites yet',
            style: AppTextStyles.headlineSmall.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'Listings you favorite will appear here.',
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.grey400,
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
          AppButton.outlined(
            label: 'Refresh',
            isFullWidth: false,
            onPressed: () => ref.read(favoritesListProvider.notifier).refresh(),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(Object error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: AppColors.errorLight,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.error_outline_rounded,
                color: AppColors.error,
                size: 40,
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(
              'Failed to load favorites',
              style: AppTextStyles.headlineSmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              error.toString(),
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: AppSpacing.xl),
            AppButton(
              label: 'Try Again',
              isFullWidth: false,
              onPressed: () => ref.read(favoritesListProvider.notifier).refresh(),
            ),
          ],
        ),
      ),
    );
  }
}
