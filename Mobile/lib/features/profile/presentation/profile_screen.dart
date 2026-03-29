import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../auth/providers/auth_providers.dart';
import '../../../core/auth/auth_provider.dart';
import '../data/me_user.dart';
import '../providers/me_profile_provider.dart';
import '../providers/wallet_providers.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  String _formatError(Object e) {
    if (e is DioException) {
      final d = e.response?.data;
      if (d is Map && d['detail'] != null) return d['detail'].toString();
      return e.message ?? 'Network error';
    }
    return e.toString();
  }

  Future<void> _showTopUpDialog() async {
    final controller = TextEditingController(text: '25');
    String? submitted;
    try {
      submitted = await showDialog<String?>(
        context: context,
        builder: (ctx) {
          return AlertDialog(
            title: const Text('Top up balance'),
            content: TextField(
              controller: controller,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}')),
              ],
              decoration: const InputDecoration(
                labelText: 'Amount (USD)',
                hintText: 'e.g. 25',
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx, null),
                child: const Text('Cancel'),
              ),
              FilledButton(
                onPressed: () => Navigator.pop(ctx, controller.text.trim()),
                child: const Text('Add'),
              ),
            ],
          );
        },
      );
    } finally {
      controller.dispose();
    }
    if (submitted == null || !mounted) return;
    final v = double.tryParse(submitted);
    if (v == null || v <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enter a valid amount')),
      );
      return;
    }

    try {
      await ref.read(walletRepositoryProvider).topUp(v);
      ref.invalidate(currentMeProvider);
      ref.invalidate(transactionHistoryProvider);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Added \$${v.toStringAsFixed(2)}')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_formatError(e)),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  Future<void> _refreshProfile() async {
    ref.invalidate(currentMeProvider);
    ref.invalidate(transactionHistoryProvider);
    await ref.read(currentMeProvider.future);
  }

  Widget _nameRow(MeUser me) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        Flexible(
          child: Text(
            me.fullName.isNotEmpty ? me.fullName : 'User',
            style: AppTextStyles.headlineSmall,
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        if (me.hasFeaturedBadge) ...[
          const SizedBox(width: 6),
          Tooltip(
            message: 'Featured seller — VIP',
            child: Icon(
              Icons.verified,
              size: 26,
              color: AppColors.info,
            ),
          ),
        ],
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final firebaseUser = ref.watch(currentUserProvider);
    final meAsync = ref.watch(currentMeProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: firebaseUser == null
          ? _LoggedOutBody(onLogin: () => context.push('/login'))
          : meAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        _formatError(e),
                        textAlign: TextAlign.center,
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: AppColors.error,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.md),
                      FilledButton(
                        onPressed: () => ref.invalidate(currentMeProvider),
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                ),
              ),
              data: (me) {
                if (me == null) {
                  return _LoggedOutBody(onLogin: () => context.push('/login'));
                }
                return RefreshIndicator(
                  color: AppColors.primary,
                  onRefresh: _refreshProfile,
                  child: ListView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.symmetric(vertical: AppSpacing.lg),
                    children: [
                      Center(
                        child: Column(
                          children: [
                            CircleAvatar(
                              radius: 50,
                              backgroundColor: AppColors.surfaceVariant,
                              child: Text(
                                (me.fullName.isNotEmpty
                                        ? me.fullName[0]
                                        : firebaseUser.email?.substring(0, 1) ?? 'U')
                                    .toUpperCase(),
                                style: AppTextStyles.headlineMedium.copyWith(
                                  color: AppColors.primary,
                                ),
                              ),
                            ),
                            const SizedBox(height: AppSpacing.md),
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: AppSpacing.md,
                              ),
                              child: _nameRow(me),
                            ),
                            const SizedBox(height: AppSpacing.sm),
                            Text(
                              firebaseUser.email ?? '',
                              style: AppTextStyles.bodySmall.copyWith(
                                color: AppColors.textSecondary,
                              ),
                            ),
                            const SizedBox(height: AppSpacing.md),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: AppSpacing.lg,
                                vertical: AppSpacing.sm,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.surface,
                                borderRadius: BorderRadius.circular(AppSpacing.md),
                                border: Border.all(color: AppColors.border),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.account_balance_wallet_outlined,
                                    size: 20,
                                    color: AppColors.primary,
                                  ),
                                  const SizedBox(width: AppSpacing.sm),
                                  Text(
                                    'Balance  \$${me.balance.toStringAsFixed(2)}',
                                    style: AppTextStyles.titleSmall.copyWith(
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: AppSpacing.lg),
                      const Divider(height: 1),
                      ListTile(
                        leading: const Icon(Icons.verified_outlined),
                        title: const Text('Featured badge'),
                        subtitle: const Text(
                          'Pricing — verified check on profile & listing',
                        ),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () => context.push('/promotions'),
                      ),
                      const Divider(height: 1),
                      ListTile(
                        leading: const Icon(Icons.add_card_outlined),
                        title: const Text('Top up balance'),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: _showTopUpDialog,
                      ),
                      const Divider(height: 1),
                      ListTile(
                        leading: const Icon(Icons.list_alt_outlined),
                        title: const Text('My Listings'),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () => context.push('/my-listings'),
                      ),
                      const Divider(height: 1),
                      ListTile(
                        leading: const Icon(Icons.receipt_long_outlined),
                        title: const Text('Transaction history'),
                        subtitle: const Text('Top ups & badge purchases'),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () {
                          ref.invalidate(transactionHistoryProvider);
                          context.push('/transaction-history');
                        },
                      ),
                      const Divider(height: 1),
                      ListTile(
                        leading: const Icon(Icons.language),
                        title: const Text('Language'),
                        trailing: const Text('EN'),
                        onTap: () {},
                      ),
                      const Divider(height: 1),
                      const SizedBox(height: AppSpacing.xl),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.lg,
                        ),
                        child: OutlinedButton.icon(
                          onPressed: () {
                            ref.read(loginProvider.notifier).logout();
                          },
                          icon: const Icon(Icons.logout, color: AppColors.error),
                          label: const Text(
                            'Log out',
                            style: TextStyle(color: AppColors.error),
                          ),
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: AppColors.error),
                            padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
    );
  }
}

class _LoggedOutBody extends StatelessWidget {
  final VoidCallback onLogin;

  const _LoggedOutBody({required this.onLogin});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.account_circle, size: 100, color: AppColors.grey400),
          const SizedBox(height: AppSpacing.md),
          Text(
            'Not signed in',
            style: AppTextStyles.titleLarge,
          ),
          const SizedBox(height: AppSpacing.md),
          FilledButton(
            onPressed: onLogin,
            child: const Text('Sign in / Register'),
          ),
        ],
      ),
    );
  }
}
