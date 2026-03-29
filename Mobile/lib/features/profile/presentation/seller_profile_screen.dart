import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../favorites/providers/favorite_providers.dart';
import '../../listings/data/models/listing.dart';
import '../data/models/public_profile.dart';
import '../providers/profile_public_providers.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/listing_card.dart';

class SellerProfileScreen extends ConsumerStatefulWidget {
  final int userId;

  const SellerProfileScreen({super.key, required this.userId});

  @override
  ConsumerState<SellerProfileScreen> createState() =>
      _SellerProfileScreenState();
}

class _SellerProfileScreenState extends ConsumerState<SellerProfileScreen> {
  final _scrollController = ScrollController();
  final List<Listing> _listings = [];
  int _offset = 0;
  bool _hasMore = true;
  bool _loadingMore = false;
  bool _initialListingsLoaded = false;
  Object? _listingsError;

  static const int _pageSize = 20;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadFirstPage());
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (!mounted || !_hasMore || _loadingMore) return;
    final maxScroll = _scrollController.position.maxScrollExtent;
    final current = _scrollController.position.pixels;
    if (current >= maxScroll * 0.85) {
      _loadMore();
    }
  }

  Future<void> _loadFirstPage() async {
    setState(() {
      _listingsError = null;
      _initialListingsLoaded = false;
    });
    try {
      final repo = ref.read(userPublicRepositoryProvider);
      final res = await repo.getUserListings(
        userId: widget.userId,
        limit: _pageSize,
        offset: 0,
      );
      if (!mounted) return;
      setState(() {
        _listings
          ..clear()
          ..addAll(res.items);
        _offset = _pageSize;
        _hasMore = res.page < res.totalPages;
        _initialListingsLoaded = true;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _listingsError = e;
        _initialListingsLoaded = true;
      });
    }
  }

  Future<void> _loadMore() async {
    if (!_hasMore || _loadingMore) return;
    setState(() => _loadingMore = true);
    try {
      final repo = ref.read(userPublicRepositoryProvider);
      final res = await repo.getUserListings(
        userId: widget.userId,
        limit: _pageSize,
        offset: _offset,
      );
      if (!mounted) return;
      setState(() {
        _listings.addAll(res.items);
        _offset += _pageSize;
        _hasMore = res.page < res.totalPages;
        _loadingMore = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _loadingMore = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final profileAsync = ref.watch(publicProfileProvider(widget.userId));
    final favoriteIds = ref.watch(favoriteIdsProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Seller'),
        backgroundColor: AppColors.surface,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
      ),
      body: RefreshIndicator(
        color: AppColors.primary,
        onRefresh: () async {
          ref.invalidate(publicProfileProvider(widget.userId));
          await _loadFirstPage();
        },
        child: profileAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Center(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Text(
                e.toString(),
                style: AppTextStyles.bodyMedium,
                textAlign: TextAlign.center,
              ),
            ),
          ),
          data: (profile) => CustomScrollView(
            controller: _scrollController,
            slivers: [
              SliverToBoxAdapter(child: _ProfileHeader(profile: profile)),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.md,
                    AppSpacing.lg,
                    AppSpacing.md,
                    AppSpacing.sm,
                  ),
                  child: Text(
                    'Active listings',
                    style: AppTextStyles.titleLarge,
                  ),
                ),
              ),
              if (!_initialListingsLoaded)
                const SliverFillRemaining(
                  hasScrollBody: false,
                  child: Center(child: CircularProgressIndicator()),
                )
              else if (_listingsError != null)
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: Center(
                    child: Text(
                      _listingsError.toString(),
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.textSecondary,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                )
              else if (_listings.isEmpty)
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: Center(
                    child: Text(
                      'No active listings yet.',
                      style: AppTextStyles.bodyLarge.copyWith(
                        color: AppColors.grey500,
                      ),
                    ),
                  ),
                )
              else
                SliverPadding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.md,
                  ),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        if (index == _listings.length) {
                          if (_loadingMore) {
                            return const Padding(
                              padding: EdgeInsets.symmetric(
                                vertical: AppSpacing.xl,
                              ),
                              child: Center(
                                child: CircularProgressIndicator(),
                              ),
                            );
                          }
                          return const SizedBox.shrink();
                        }
                        final listing = _listings[index];
                        final primaryImage = listing.images.isNotEmpty
                            ? listing.images
                                .firstWhere(
                                  (img) => img.isPrimary,
                                  orElse: () => listing.images.first,
                                )
                                .fileUrl
                            : null;
                        return Padding(
                          padding: const EdgeInsets.only(bottom: AppSpacing.md),
                          child: ListingCard(
                            title: listing.title,
                            price: '${listing.price.toInt()} ${listing.currency}',
                            city: listing.city,
                            imageUrl: primaryImage,
                            isPromoted: listing.promotionStatus == 'active',
                            isFavorited: favoriteIds.contains(listing.id),
                            onFavoriteTap: () {
                              ref
                                  .read(favoriteIdsProvider.notifier)
                                  .toggleFavorite(listing.id);
                            },
                            onTap: () {
                              context.push(
                                '/listing/${listing.id}',
                                extra: listing,
                              );
                            },
                          ),
                        );
                      },
                      childCount: _listings.length + (_hasMore ? 1 : 0),
                    ),
                  ),
                ),
              const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.xl)),
            ],
          ),
        ),
      ),
    );
  }
}

class _ProfileHeader extends StatelessWidget {
  final PublicProfile profile;

  const _ProfileHeader({required this.profile});

  @override
  Widget build(BuildContext context) {
    final since = DateFormat.yMMMM().format(profile.memberSince);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.lg),
      color: AppColors.surface,
      child: Column(
        children: [
          CircleAvatar(
            radius: 48,
            backgroundColor: AppColors.grey200,
            backgroundImage: profile.profileImageUrl != null &&
                    profile.profileImageUrl!.isNotEmpty
                ? CachedNetworkImageProvider(profile.profileImageUrl!)
                : null,
            child: profile.profileImageUrl == null ||
                    profile.profileImageUrl!.isEmpty
                ? Text(
                    profile.fullName.isNotEmpty
                        ? profile.fullName[0].toUpperCase()
                        : '?',
                    style: AppTextStyles.headlineMedium.copyWith(
                      color: AppColors.primary,
                    ),
                  )
                : null,
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            profile.fullName,
            style: AppTextStyles.headlineSmall,
            textAlign: TextAlign.center,
          ),
          if (profile.city != null && profile.city!.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.xs),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.location_on_outlined,
                  size: 18,
                  color: AppColors.grey500,
                ),
                const SizedBox(width: 4),
                Text(
                  profile.city!,
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ],
          const SizedBox(height: AppSpacing.sm),
          Text(
            'Member since $since · ${profile.activeListingCount} listing${profile.activeListingCount == 1 ? '' : 's'}',
            style: AppTextStyles.bodySmall.copyWith(color: AppColors.grey500),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
