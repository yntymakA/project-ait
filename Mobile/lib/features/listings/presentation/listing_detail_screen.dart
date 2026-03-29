import 'package:cached_network_image/cached_network_image.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../core/auth/auth_provider.dart';
import '../data/models/listing.dart';
import '../providers/listing_providers.dart';
import '../../favorites/providers/favorite_providers.dart';
import '../../profile/providers/profile_public_providers.dart';
import '../../reports/providers/report_providers.dart';
import '../../profile/providers/me_profile_provider.dart';
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

  void _openReportSellerDialog(int ownerId) {
    final user = ref.read(currentUserProvider);
    if (user == null) {
      context.push('/login');
      return;
    }
    showDialog<void>(
      context: context,
      builder: (ctx) => _ReportSellerDialog(ownerId: ownerId),
    );
  }

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
                  Text('Seller', style: AppTextStyles.titleLarge),
                  const SizedBox(height: AppSpacing.sm),
                  _SellerPreviewRow(ownerId: listing.ownerId),
                  const SizedBox(height: AppSpacing.md),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: TextButton.icon(
                      onPressed: () => _openReportSellerDialog(listing.ownerId),
                      icon: const Icon(Icons.flag_outlined, size: 18),
                      label: const Text('Пожаловаться на этого продавца'),
                      style: TextButton.styleFrom(
                        foregroundColor: AppColors.grey600,
                        textStyle: AppTextStyles.bodyMedium.copyWith(
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
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
                  onPressed: () async {
                    final firebaseUser = ref.read(currentUserProvider);
                    if (firebaseUser == null) {
                      context.push('/login');
                      return;
                    }
                    try {
                      final me = await ref.read(currentMeProvider.future);
                      if (!context.mounted) return;
                      if (me == null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Не удалось загрузить профиль'),
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                        return;
                      }
                      if (me.id == listing.ownerId) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Это ваше объявление'),
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                        return;
                      }
                      context.push('/listing/${listing.id}/chat', extra: listing);
                    } catch (_) {
                      if (!context.mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Не удалось открыть чат'),
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    }
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

class _SellerPreviewRow extends ConsumerWidget {
  final int ownerId;

  const _SellerPreviewRow({required this.ownerId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(publicProfileProvider(ownerId));

    return async.when(
      loading: () => const Padding(
        padding: EdgeInsets.symmetric(vertical: AppSpacing.sm),
        child: LinearProgressIndicator(minHeight: 2),
      ),
      error: (e, st) => const SizedBox.shrink(),
      data: (profile) => Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: AppSpacing.rounded,
          border: Border.all(color: AppColors.border),
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () => context.push('/users/$ownerId'),
            borderRadius: AppSpacing.rounded,
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 28,
                    backgroundColor: AppColors.grey200,
                    backgroundImage:
                        profile.profileImageUrl != null &&
                                profile.profileImageUrl!.isNotEmpty
                            ? CachedNetworkImageProvider(profile.profileImageUrl!)
                            : null,
                    child: profile.profileImageUrl == null ||
                            profile.profileImageUrl!.isEmpty
                        ? Text(
                            profile.fullName.isNotEmpty
                                ? profile.fullName[0].toUpperCase()
                                : '?',
                            style: AppTextStyles.titleLarge.copyWith(
                              color: AppColors.primary,
                            ),
                          )
                        : null,
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          profile.fullName,
                          style: AppTextStyles.titleMedium,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'View profile and listings',
                          style: AppTextStyles.bodySmall.copyWith(
                            color: AppColors.grey500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Icon(
                    Icons.chevron_right,
                    color: AppColors.grey400,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ReportSellerDialog extends ConsumerStatefulWidget {
  final int ownerId;

  const _ReportSellerDialog({required this.ownerId});

  @override
  ConsumerState<_ReportSellerDialog> createState() => _ReportSellerDialogState();
}

class _ReportSellerDialogState extends ConsumerState<_ReportSellerDialog> {
  final _controller = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _submitting = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    setState(() => _submitting = true);
    try {
      await ref.read(reportRepositoryProvider).submitUserReport(
            targetUserId: widget.ownerId,
            reasonText: _controller.text.trim(),
          );
      if (!mounted) return;
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Жалоба отправлена'),
          backgroundColor: AppColors.success,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } on DioException catch (e) {
      if (!mounted) return;
      final detail = e.response?.data;
      final msg = detail is Map && detail['detail'] != null
          ? detail['detail'].toString()
          : (e.message ?? 'Не удалось отправить жалобу');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(msg),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Не удалось отправить жалобу'),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Жалоба на продавца'),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: TextFormField(
            controller: _controller,
            maxLines: 5,
            maxLength: 2000,
            decoration: const InputDecoration(
              labelText: 'Опишите причину',
              alignLabelWithHint: true,
              border: OutlineInputBorder(),
            ),
            validator: (v) {
              if (v == null || v.trim().isEmpty) {
                return 'Введите описание';
              }
              return null;
            },
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _submitting ? null : () => Navigator.of(context).pop(),
          child: const Text('Отмена'),
        ),
        FilledButton(
          onPressed: _submitting ? null : _submit,
          child: _submitting
              ? const SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Отправить'),
        ),
      ],
    );
  }
}
