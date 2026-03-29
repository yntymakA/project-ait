import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../data/models/promotion_package.dart';
import '../providers/me_profile_provider.dart';
import '../providers/wallet_providers.dart';

/// Featured-badge packages only (API filters to `promotion_type == featured`).
class PromotionsScreen extends ConsumerWidget {
  const PromotionsScreen({super.key});

  String _formatError(Object e) {
    if (e is DioException) {
      final d = e.response?.data;
      if (d is Map && d['detail'] != null) return d['detail'].toString();
      return e.message ?? 'Network error';
    }
    return e.toString();
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final packagesAsync = ref.watch(promotionPackagesProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Featured badge'),
        surfaceTintColor: Colors.transparent,
      ),
      body: packagesAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Text(
              e.toString(),
              textAlign: TextAlign.center,
              style: AppTextStyles.bodyMedium.copyWith(color: AppColors.error),
            ),
          ),
        ),
        data: (items) {
          final featuredOnly = items
              .where((p) => p.durationDays == 7 || p.durationDays == 30)
              .toList()
            ..sort((a, b) => a.durationDays.compareTo(b.durationDays));

          if (featuredOnly.isEmpty) {
            return Center(
              child: Text(
                'Featured 7/30 day packages are not available.',
                style: AppTextStyles.bodyLarge.copyWith(color: AppColors.grey500),
              ),
            );
          }
          return ListView(
            padding: const EdgeInsets.all(AppSpacing.md),
            children: [
              Text(
                'Choose your Featured badge duration. Purchase activates instantly and decorates your profile with the verified badge while active.',
                style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
              ),
              const SizedBox(height: AppSpacing.lg),
              ...featuredOnly.map((p) => _PackageCard(
                    package: p,
                    onBuy: () async {
                      await ref.read(walletRepositoryProvider).purchaseFeatured(
                            packageId: p.id,
                          );
                      ref.invalidate(currentMeProvider);
                      ref.invalidate(transactionHistoryProvider);
                      ref.invalidate(promotionPackagesProvider);
                    },
                    formatError: _formatError,
                  )),
            ],
          );
        },
      ),
    );
  }
}

class _PackageCard extends StatefulWidget {
  final PromotionPackage package;
  final Future<void> Function() onBuy;
  final String Function(Object e) formatError;

  const _PackageCard({
    required this.package,
    required this.onBuy,
    required this.formatError,
  });

  @override
  State<_PackageCard> createState() => _PackageCardState();
}

class _PackageCardState extends State<_PackageCard> {
  bool _isBuying = false;

  Future<void> _buy() async {
    if (_isBuying) return;
    setState(() => _isBuying = true);
    try {
      await widget.onBuy();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Featured activated for ${widget.package.durationDays} days',
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(widget.formatError(e)),
          backgroundColor: AppColors.error,
        ),
      );
    } finally {
      if (mounted) setState(() => _isBuying = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      elevation: 0,
      color: AppColors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSpacing.md),
        side: const BorderSide(color: AppColors.border),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    widget.package.name,
                    style: AppTextStyles.titleSmall,
                  ),
                ),
                Text(
                  '\$${widget.package.price.toStringAsFixed(2)}',
                  style: AppTextStyles.titleSmall.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              'Verified badge on profile & listing',
              style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary),
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              '${widget.package.durationDays} day${widget.package.durationDays == 1 ? '' : 's'}',
              style: AppTextStyles.labelSmall.copyWith(color: AppColors.grey500),
            ),
            const SizedBox(height: AppSpacing.md),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: _isBuying ? null : _buy,
                child: _isBuying
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Buy'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
