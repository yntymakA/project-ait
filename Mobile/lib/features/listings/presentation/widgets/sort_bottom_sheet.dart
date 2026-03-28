import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../providers/feed_filters_provider.dart';

class SortBottomSheet extends ConsumerWidget {
  const SortBottomSheet({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentSort = ref.watch(feedFiltersProvider).sort;

    return Container(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
            child: Text(
              'Sort By',
              style: AppTextStyles.headlineSmall,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          _buildSortOption(
            context,
            ref,
            title: 'Newest listed',
            value: 'newest',
            isSelected: currentSort == 'newest',
          ),
          _buildSortOption(
            context,
            ref,
            title: 'Oldest listed',
            value: 'oldest',
            isSelected: currentSort == 'oldest',
          ),
          _buildSortOption(
            context,
            ref,
            title: 'Price (Low to High)',
            value: 'price_asc',
            isSelected: currentSort == 'price_asc',
          ),
          _buildSortOption(
            context,
            ref,
            title: 'Price (High to Low)',
            value: 'price_desc',
            isSelected: currentSort == 'price_desc',
          ),
          const SizedBox(height: AppSpacing.xl),
        ],
      ),
    );
  }

  Widget _buildSortOption(
    BuildContext context,
    WidgetRef ref, {
    required String title,
    required String value,
    required bool isSelected,
  }) {
    return InkWell(
      onTap: () {
        ref.read(feedFiltersProvider.notifier).updateSort(value);
        Navigator.of(context).pop();
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: AppTextStyles.bodyLarge.copyWith(
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                color: isSelected ? AppColors.primary : AppColors.textPrimary,
              ),
            ),
            if (isSelected) 
              const Icon(Icons.check, color: AppColors.primary),
          ],
        ),
      ),
    );
  }
}
