import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../theme/app_spacing.dart';

/// A reusable listing card used in Feed, Search, Favorites, and Profile screens.
class ListingCard extends StatelessWidget {
  final String title;
  final String price;
  final String city;
  final String? imageUrl;
  final bool isFavorited;
  final bool isPromoted;
  final VoidCallback? onTap;
  final VoidCallback? onFavoriteTap;

  const ListingCard({
    super.key,
    required this.title,
    required this.price,
    required this.city,
    this.imageUrl,
    this.isFavorited = false,
    this.isPromoted = false,
    this.onTap,
    this.onFavoriteTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: AppSpacing.rounded,
          border: Border.all(color: AppColors.border),
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- Image ---
            Stack(
              children: [
                AspectRatio(
                  aspectRatio: 4 / 3,
                  child: imageUrl != null
                      ? Image.network(
                          imageUrl!,
                          fit: BoxFit.cover,
                          errorBuilder: (ctx, err, stack) => _placeholder(),
                          loadingBuilder: (ctx, child, progress) =>
                              progress == null ? child : _shimmer(),
                        )
                      : _placeholder(),
                ),
                // Promoted badge
                if (isPromoted)
                  Positioned(
                    top: AppSpacing.sm,
                    left: AppSpacing.sm,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.sm,
                        vertical: AppSpacing.xs,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.secondary,
                        borderRadius: AppSpacing.roundedFull,
                      ),
                      child: Text(
                        'Promoted',
                        style: AppTextStyles.labelSmall.copyWith(
                          color: AppColors.textOnSecondary,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                // Favorite button
                Positioned(
                  top: AppSpacing.xs,
                  right: AppSpacing.xs,
                  child: Material(
                    color: AppColors.surface,
                    shape: const CircleBorder(),
                    elevation: 2,
                    shadowColor: AppColors.blackWithOpacity(0.12),
                    child: InkWell(
                      onTap: onFavoriteTap,
                      customBorder: const CircleBorder(),
                      child: Padding(
                        padding: const EdgeInsets.all(AppSpacing.xs),
                        child: Icon(
                          isFavorited ? Icons.favorite : Icons.favorite_border,
                          size: AppSpacing.iconMd,
                          color: isFavorited ? AppColors.error : AppColors.grey400,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),

            // --- Info ---
            Padding(
              padding: const EdgeInsets.all(AppSpacing.sm),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTextStyles.titleMedium,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    price,
                    style: AppTextStyles.price,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Row(
                    children: [
                      const Icon(
                        Icons.location_on_outlined,
                        size: AppSpacing.iconSm,
                        color: AppColors.grey400,
                      ),
                      const SizedBox(width: 2),
                      Expanded(
                        child: Text(
                          city,
                          style: AppTextStyles.caption,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _placeholder() {
    return Container(
      color: AppColors.grey100,
      child: const Center(
        child: Icon(Icons.image_outlined, size: 40, color: AppColors.grey300),
      ),
    );
  }

  Widget _shimmer() {
    return Container(color: AppColors.grey100);
  }
}
