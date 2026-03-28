import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/app_button.dart';
import '../../providers/feed_filters_provider.dart';

class FilterBottomSheet extends ConsumerStatefulWidget {
  const FilterBottomSheet({super.key});

  @override
  ConsumerState<FilterBottomSheet> createState() => _FilterBottomSheetState();
}

class _FilterBottomSheetState extends ConsumerState<FilterBottomSheet> {
  final TextEditingController _categoryController = TextEditingController();
  final TextEditingController _cityController = TextEditingController();
  final TextEditingController _minPriceController = TextEditingController();
  final TextEditingController _maxPriceController = TextEditingController();

  @override
  void initState() {
    super.initState();
    final filters = ref.read(feedFiltersProvider);
    _categoryController.text = filters.categoryId != null ? filters.categoryId.toString() : '';
    _cityController.text = filters.city ?? '';
    _minPriceController.text = filters.minPrice != null ? filters.minPrice.toString() : '';
    _maxPriceController.text = filters.maxPrice != null ? filters.maxPrice.toString() : '';
  }

  @override
  void dispose() {
    _categoryController.dispose();
    _cityController.dispose();
    _minPriceController.dispose();
    _maxPriceController.dispose();
    super.dispose();
  }

  void _applyFilters() {
    final categoryId = int.tryParse(_categoryController.text.trim());
    final city = _cityController.text.trim();
    final minPrice = double.tryParse(_minPriceController.text.trim());
    final maxPrice = double.tryParse(_maxPriceController.text.trim());

    ref.read(feedFiltersProvider.notifier).applyFilters(
      categoryId: categoryId,
      city: city.isEmpty ? null : city,
      minPrice: minPrice,
      maxPrice: maxPrice,
    );
    Navigator.of(context).pop();
  }

  void _clearFilters() {
    _categoryController.clear();
    _cityController.clear();
    _minPriceController.clear();
    _maxPriceController.clear();
    ref.read(feedFiltersProvider.notifier).applyFilters(
      categoryId: null,
      city: null,
      minPrice: null,
      maxPrice: null,
    );
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.md),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildHeader(),
          const Divider(height: AppSpacing.xl),
          Expanded(
            child: ListView(
              children: [
                _buildCategorySection(),
                const SizedBox(height: AppSpacing.lg),
                _buildCitySection(),
                const SizedBox(height: AppSpacing.lg),
                _buildPriceSection(),
                const SizedBox(height: AppSpacing.xxl),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom + AppSpacing.md),
            child: AppButton(
              label: 'Apply Filters',
              onPressed: _applyFilters,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text('Filters', style: AppTextStyles.headlineSmall),
        TextButton(
          onPressed: _clearFilters,
          child: const Text('Reset', style: TextStyle(color: AppColors.grey600)),
        ),
      ],
    );
  }

  Widget _buildCategorySection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Category ID', style: AppTextStyles.titleMedium),
        const SizedBox(height: AppSpacing.sm),
        TextField(
          controller: _categoryController,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            hintText: 'e.g. 1',
            border: OutlineInputBorder(
              borderRadius: AppSpacing.rounded,
              borderSide: const BorderSide(color: AppColors.border),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
          ),
        ),
      ],
    );
  }

  Widget _buildCitySection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('City', style: AppTextStyles.titleMedium),
        const SizedBox(height: AppSpacing.sm),
        TextField(
          controller: _cityController,
          decoration: InputDecoration(
            hintText: 'e.g. Bishkek',
            border: OutlineInputBorder(
              borderRadius: AppSpacing.rounded,
              borderSide: const BorderSide(color: AppColors.border),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
          ),
        ),
      ],
    );
  }

  Widget _buildPriceSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Price Range', style: AppTextStyles.titleMedium),
        const SizedBox(height: AppSpacing.sm),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _minPriceController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  hintText: 'Min',
                  prefixText: '\$ ',
                  border: OutlineInputBorder(
                    borderRadius: AppSpacing.rounded,
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
                ),
              ),
            ),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: AppSpacing.sm),
              child: Text('-'),
            ),
            Expanded(
              child: TextField(
                controller: _maxPriceController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  hintText: 'Max',
                  prefixText: '\$ ',
                  border: OutlineInputBorder(
                    borderRadius: AppSpacing.rounded,
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
