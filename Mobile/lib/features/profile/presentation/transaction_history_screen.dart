import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../data/models/account_transaction.dart';
import '../providers/wallet_providers.dart';

class TransactionHistoryScreen extends ConsumerWidget {
  const TransactionHistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(transactionHistoryProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Transaction history'),
        surfaceTintColor: Colors.transparent,
      ),
      body: async.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  e.toString(),
                  textAlign: TextAlign.center,
                  style: AppTextStyles.bodyMedium.copyWith(color: AppColors.error),
                ),
                const SizedBox(height: AppSpacing.md),
                FilledButton(
                  onPressed: () => ref.invalidate(transactionHistoryProvider),
                  child: const Text('Retry'),
                ),
              ],
            ),
          ),
        ),
        data: (items) {
          if (items.isEmpty) {
            return RefreshIndicator(
              color: AppColors.primary,
              onRefresh: () async {
                ref.invalidate(transactionHistoryProvider);
                await ref.read(transactionHistoryProvider.future);
              },
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                children: [
                  SizedBox(
                    height: MediaQuery.sizeOf(context).height * 0.3,
                  ),
                  Center(
                    child: Text(
                      'No transactions yet',
                      style: AppTextStyles.bodyLarge.copyWith(
                        color: AppColors.grey500,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }
          return RefreshIndicator(
            color: AppColors.primary,
            onRefresh: () async {
              ref.invalidate(transactionHistoryProvider);
              await ref.read(transactionHistoryProvider.future);
            },
            child: ListView.separated(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(AppSpacing.md),
              itemCount: items.length,
              separatorBuilder: (context, index) =>
                  const SizedBox(height: AppSpacing.sm),
              itemBuilder: (context, index) {
                final t = items[index];
                return _TransactionTile(transaction: t);
              },
            ),
          );
        },
      ),
    );
  }
}

class _TransactionTile extends StatelessWidget {
  final AccountTransaction transaction;

  const _TransactionTile({required this.transaction});

  @override
  Widget build(BuildContext context) {
    final isIn = transaction.isTopUp;
    final color = isIn ? AppColors.success : AppColors.error;
    final prefix = isIn ? '+' : '−';
    final desc = transaction.description?.toLowerCase() ?? '';
    final title = isIn
        ? 'Top up'
        : (desc.contains('featured badge')
            ? 'Featured badge'
            : 'Purchase');
    final subtitle = transaction.description?.trim();
    final amountLabel =
        '$prefix\$${transaction.amount.abs().toStringAsFixed(2)}';

    return Material(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(AppSpacing.md),
      child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                isIn ? Icons.add_card_outlined : Icons.verified_outlined,
                color: color,
                size: 28,
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: AppTextStyles.titleSmall),
                    if (subtitle != null && subtitle.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                    const SizedBox(height: 4),
                    Text(
                      transaction.formattedTime(),
                      style: AppTextStyles.labelSmall.copyWith(
                        color: AppColors.grey500,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                amountLabel,
                style: AppTextStyles.titleSmall.copyWith(
                  color: color,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
    );
  }
}
