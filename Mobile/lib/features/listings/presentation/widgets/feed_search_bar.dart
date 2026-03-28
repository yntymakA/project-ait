import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../providers/feed_filters_provider.dart';
import 'filter_bottom_sheet.dart';
import 'sort_bottom_sheet.dart';

class FeedSearchBar extends ConsumerStatefulWidget {
  const FeedSearchBar({super.key});

  @override
  ConsumerState<FeedSearchBar> createState() => _FeedSearchBarState();
}

class _FeedSearchBarState extends ConsumerState<FeedSearchBar> {
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _searchController.text = ref.read(feedFiltersProvider).query;
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Sync controller when filters are reset externally (e.g. clearFilters)
    ref.listen<FeedFilters>(feedFiltersProvider, (prev, next) {
      if (next.query != _searchController.text) {
        _searchController.text = next.query;
      }
    });

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
      color: AppColors.background,
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _searchController,
              onSubmitted: (value) {
                ref.read(feedFiltersProvider.notifier).updateQuery(value);
              },
              textInputAction: TextInputAction.search,
              decoration: InputDecoration(
                hintText: 'Search listings...',
                prefixIcon: const Icon(Icons.search, color: AppColors.grey500),
                contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: AppSpacing.sm),
                border: OutlineInputBorder(
                  borderRadius: AppSpacing.rounded,
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: AppColors.surface,
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Container(
            decoration: const BoxDecoration(
              color: AppColors.surface,
              shape: BoxShape.circle,
            ),
            child: IconButton(
              icon: const Icon(Icons.tune, color: AppColors.textPrimary),
              onPressed: () {
                showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  backgroundColor: Colors.transparent,
                  builder: (context) => const FilterBottomSheet(),
                );
              },
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Container(
            decoration: const BoxDecoration(
              color: AppColors.surface,
              shape: BoxShape.circle,
            ),
            child: IconButton(
              icon: const Icon(Icons.sort, color: AppColors.textPrimary),
              onPressed: () {
                showModalBottomSheet(
                  context: context,
                  backgroundColor: Colors.transparent,
                  builder: (context) => const SortBottomSheet(),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
