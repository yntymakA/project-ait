import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/l10n/l10n.dart';
import '../../../core/l10n/locale_provider.dart';
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
            title: Text(context.l10n.profileTopUpTitle),
            content: TextField(
              controller: controller,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}')),
              ],
              decoration: InputDecoration(
                labelText: context.l10n.profileAmountLabel,
                hintText: context.l10n.profileAmountHint,
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx, null),
                child: Text(context.l10n.commonCancel),
              ),
              FilledButton(
                onPressed: () => Navigator.pop(ctx, controller.text.trim()),
                child: Text(context.l10n.commonAdd),
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
        SnackBar(content: Text(context.l10n.profileInvalidAmount)),
      );
      return;
    }

    try {
      await ref.read(walletRepositoryProvider).topUp(v);
      ref.invalidate(currentMeProvider);
      ref.invalidate(transactionHistoryProvider);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              context.l10n.profileAddedAmount('\$${v.toStringAsFixed(2)}'),
            ),
          ),
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

  String _languageLabel(Locale? locale) {
    final l10n = context.l10n;
    switch (locale?.languageCode) {
      case 'en':
        return l10n.languageEnglish;
      case 'ru':
        return l10n.languageRussian;
      default:
        return l10n.languageSystem;
    }
  }

  Future<void> _showLanguageDialog() async {
    final locale = ref.read(appLocaleProvider);
    final selected = await showModalBottomSheet<String?>(
      context: context,
      showDragHandle: true,
      builder: (ctx) {
        final l10n = ctx.l10n;
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                title: Text(l10n.languageDialogTitle),
              ),
              ListTile(
                title: Text(l10n.languageSystem),
                trailing: locale == null ? const Icon(Icons.check) : null,
                onTap: () => Navigator.pop(ctx, null),
              ),
              ListTile(
                title: Text(l10n.languageEnglish),
                trailing: locale?.languageCode == 'en' ? const Icon(Icons.check) : null,
                onTap: () => Navigator.pop(ctx, 'en'),
              ),
              ListTile(
                title: Text(l10n.languageRussian),
                trailing: locale?.languageCode == 'ru' ? const Icon(Icons.check) : null,
                onTap: () => Navigator.pop(ctx, 'ru'),
              ),
              const SizedBox(height: AppSpacing.sm),
            ],
          ),
        );
      },
    );

    if (!mounted) return;
    if (selected == locale?.languageCode) return;
    await ref.read(appLocaleProvider.notifier).setLocaleCode(selected);
  }

  Widget _nameRow(MeUser me) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        Flexible(
          child: Text(
            me.fullName.isNotEmpty ? me.fullName : context.l10n.profileDefaultName,
            style: AppTextStyles.headlineSmall,
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        if (me.hasFeaturedBadge) ...[
          const SizedBox(width: 6),
          Tooltip(
            message: context.l10n.profileFeaturedTooltip,
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
    final selectedLocale = ref.watch(appLocaleProvider);

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
                        child: Text(context.l10n.commonRetry),
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
                                    '${context.l10n.profileBalanceLabel}  \$${me.balance.toStringAsFixed(2)}',
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
                        title: Text(context.l10n.profileFeaturedBadge),
                        subtitle: Text(context.l10n.profileFeaturedSubtitle),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () => context.push('/promotions'),
                      ),
                      const Divider(height: 1),
                      ListTile(
                        leading: const Icon(Icons.add_card_outlined),
                        title: Text(context.l10n.profileTopUpBalance),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: _showTopUpDialog,
                      ),
                      const Divider(height: 1),
                      ListTile(
                        leading: const Icon(Icons.list_alt_outlined),
                        title: Text(context.l10n.profileMyListings),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () => context.push('/my-listings'),
                      ),
                      const Divider(height: 1),
                      ListTile(
                        leading: const Icon(Icons.receipt_long_outlined),
                        title: Text(context.l10n.profileTransactionHistory),
                        subtitle: Text(context.l10n.profileTransactionSubtitle),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () {
                          ref.invalidate(transactionHistoryProvider);
                          context.push('/transaction-history');
                        },
                      ),
                      const Divider(height: 1),
                      ListTile(
                        leading: const Icon(Icons.language),
                        title: Text(context.l10n.settingsLanguage),
                        trailing: Text(_languageLabel(selectedLocale)),
                        onTap: _showLanguageDialog,
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
                          label: Text(
                            context.l10n.profileLogout,
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
            context.l10n.profileNotSignedIn,
            style: AppTextStyles.titleLarge,
          ),
          const SizedBox(height: AppSpacing.md),
          FilledButton(
            onPressed: onLogin,
            child: Text(context.l10n.profileSignInRegister),
          ),
        ],
      ),
    );
  }
}
