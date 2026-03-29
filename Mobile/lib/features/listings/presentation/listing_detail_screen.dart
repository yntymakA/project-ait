import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../data/models/listing.dart';
import '../providers/listing_providers.dart';
import '../../favorites/providers/favorite_providers.dart';
import '../../../core/maps/listing_map_preview.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/app_button.dart';

class ListingDetailScreen extends ConsumerStatefulWidget {
  final int listingId;
  final Listing? listing;

  const ListingDetailScreen({
    super.key,
    required this.listingId,
    this.listing,
  });

  @override
  ConsumerState<ListingDetailScreen> createState() => _ListingDetailScreenState();
}

class _ListingDetailScreenState extends ConsumerState<ListingDetailScreen> {
  final PageController _pageController = PageController();
  int _currentImageIndex = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // If we have the listing passed from Feed, use it immediately
    if (widget.listing != null) {
      return _buildContent(context, widget.listing!);
    }

    // Otherwise fetch from provider (e.g., deep linking or refreshed page)
    final listingAsync = ref.watch(listingDetailProvider(widget.listingId));

    return Scaffold(
      backgroundColor: AppColors.background,
      body: listingAsync.when(
        data: (listing) => _buildContent(context, listing),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 48, color: AppColors.error),
              const SizedBox(height: AppSpacing.md),
              Text(
                'Failed to load listing',
                style: AppTextStyles.titleMedium,
              ),
              const SizedBox(height: AppSpacing.sm),
              AppButton.outlined(
                label: 'Go Back',
                isFullWidth: false,
                onPressed: () => context.pop(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context, Listing listing) {
    // Sort images by order_index just to be safe
    final images = List<ListingImage>.from(listing.images)
      ..sort((a, b) => a.orderIndex.compareTo(b.orderIndex));

    final favoriteIds = ref.watch(favoriteIdsProvider);
    final isFavorited = favoriteIds.contains(listing.id);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          // Collapsible Image App Bar
          SliverAppBar(
            expandedHeight: 300,
            pinned: true,
            backgroundColor: AppColors.surface,
            leading: Padding(
              padding: const EdgeInsets.all(8.0),
              child: CircleAvatar(
                backgroundColor: AppColors.blackWithOpacity(0.4),
                child: IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.white),
                  onPressed: () => context.pop(),
                ),
              ),
            ),
            actions: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: CircleAvatar(
                  backgroundColor: AppColors.blackWithOpacity(0.4),
                  child: IconButton(
                    icon: Icon(
                      isFavorited ? Icons.favorite : Icons.favorite_border,
                      color: isFavorited ? AppColors.error : Colors.white,
                    ),
                    onPressed: () {
                      ref.read(favoriteIdsProvider.notifier).toggleFavorite(listing.id);
                    },
                  ),
                ),
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: images.isNotEmpty
                  ? Stack(
                      children: [
                        PageView.builder(
                          controller: _pageController,
                          onPageChanged: (index) {
                            setState(() {
                              _currentImageIndex = index;
                            });
                          },
                          itemCount: images.length,
                          itemBuilder: (context, index) {
                            return Image.network(
                              images[index].fileUrl,
                              fit: BoxFit.cover,
                              width: double.infinity,
                            );
                          },
                        ),
                        // Dots Indicator
                        if (images.length > 1)
                          Positioned(
                            bottom: AppSpacing.md,
                            left: 0,
                            right: 0,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: List.generate(
                                images.length,
                                (index) => AnimatedContainer(
                                  duration: const Duration(milliseconds: 300),
                                  margin: const EdgeInsets.symmetric(horizontal: 4),
                                  width: _currentImageIndex == index ? 24 : 8,
                                  height: 8,
                                  decoration: BoxDecoration(
                                    color: _currentImageIndex == index
                                        ? AppColors.primary
                                        : Colors.white.withOpacity(0.5),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                ),
                              ),
                            ),
                          ),
                      ],
                    )
                  : Container(
                      color: AppColors.grey200,
                      child: const Center(
                        child: Icon(Icons.image_outlined, size: 64, color: AppColors.grey400),
                      ),
                    ),
            ),
          ),

          // Main Listing Info
          SliverToBoxAdapter(
            child: Container(
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: AppColors.surface,
                border: Border(bottom: BorderSide(color: AppColors.border)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          listing.title,
                          style: AppTextStyles.headlineSmall,
                        ),
                      ),
                      if (listing.isNegotiable)
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: AppSpacing.sm, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppColors.successLight,
                            borderRadius: AppSpacing.roundedSm,
                          ),
                          child: Text(
                            'Negotiable',
                            style: AppTextStyles.labelSmall.copyWith(
                              color: AppColors.success,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    '\$${listing.price.toInt()} ${listing.currency}',
                    style: AppTextStyles.headlineMedium.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  Row(
                    children: [
                      const Icon(Icons.location_on_outlined, color: AppColors.grey500),
                      const SizedBox(width: AppSpacing.xs),
                      Text(
                        listing.city,
                        style: AppTextStyles.bodyLarge.copyWith(color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                  if (listing.latitude != null && listing.longitude != null) ...[
                    const SizedBox(height: AppSpacing.md),
                    ListingMapPreview(
                      latitude: listing.latitude!,
                      longitude: listing.longitude!,
                      height: 200,
                    ),
                  ],
                  const SizedBox(height: AppSpacing.xs),
                  Row(
                    children: [
                      const Icon(Icons.access_time, color: AppColors.grey500),
                      const SizedBox(width: AppSpacing.xs),
                      Text(
                        'Posted ${DateFormat.yMMMd().format(listing.createdAt)}',
                        style: AppTextStyles.bodyMedium.copyWith(color: AppColors.grey500),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // Description Section
          SliverToBoxAdapter(
            child: Container(
              margin: const EdgeInsets.only(top: AppSpacing.sm),
              padding: const EdgeInsets.all(AppSpacing.md),
              color: AppColors.surface,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Description', style: AppTextStyles.titleLarge),
                  const SizedBox(height: AppSpacing.md),
                  Text(
                    listing.description,
                    style: AppTextStyles.bodyLarge.copyWith(height: 1.5),
                  ),
                  const SizedBox(height: AppSpacing.xl),
                ],
              ),
            ),
          ),
          
          // Padding to allow scrolling past bottom bar
          const SliverToBoxAdapter(
            child: SizedBox(height: 100),
          )
        ],
      ),
      
      // Bottom Action Bar Fixed
      bottomSheet: Container(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.md),
        decoration: BoxDecoration(
          color: AppColors.surface,
          boxShadow: [
            BoxShadow(
              color: AppColors.blackWithOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, -4),
            )
          ],
        ),
        child: SafeArea(
          child: Row(
            children: [
              Expanded(
                child: AppButton.outlined(
                  label: 'Call Seller',
                  onPressed: () {
                    // Call logic
                  },
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: AppButton(
                  label: 'Chat',
                  onPressed: () {
                    // Navigate to chat
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
