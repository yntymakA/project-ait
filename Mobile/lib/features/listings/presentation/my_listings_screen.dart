import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../data/models/listing.dart';
import '../providers/my_listings_provider.dart';
import '../../../core/theme/app_colors.dart';

class MyListingsScreen extends ConsumerWidget {
  const MyListingsScreen({super.key});

  String _statusLabel(String moderationStatus) {
    switch (moderationStatus.toLowerCase()) {
      case 'approved':
        return 'Live';
      case 'pending':
        return 'Pending review';
      case 'rejected':
        return 'Rejected';
      default:
        return moderationStatus;
    }
  }

  Color _statusColor(String moderationStatus) {
    switch (moderationStatus.toLowerCase()) {
      case 'approved':
        return AppColors.success;
      case 'pending':
        return AppColors.warning;
      case 'rejected':
        return AppColors.error;
      default:
        return AppColors.textSecondary;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(myListingsProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('My listings', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: AppColors.surface,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
      ),
      body: async.when(
        data: (page) {
          if (page.items.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.inventory_2_outlined, size: 64, color: Colors.grey[400]),
                    const SizedBox(height: 16),
                    Text(
                      'No listings yet',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.grey[800]),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Create a listing from the Post tab.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                  ],
                ),
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () async {
              ref.invalidate(myListingsProvider);
              await ref.read(myListingsProvider.future);
            },
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
              itemCount: page.items.length,
              separatorBuilder: (context, index) => const SizedBox(height: 10),
              itemBuilder: (context, index) {
                final listing = page.items[index];
                return _ListingTile(
                  listing: listing,
                  statusLabel: _statusLabel(listing.moderationStatus),
                  statusColor: _statusColor(listing.moderationStatus),
                  onTap: () => context.push('/edit-listing/${listing.id}'),
                );
              },
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, size: 48, color: AppColors.error),
                const SizedBox(height: 12),
                Text('Could not load your listings', style: TextStyle(color: Colors.grey[800], fontWeight: FontWeight.w600)),
                const SizedBox(height: 8),
                Text('$e', textAlign: TextAlign.center, style: TextStyle(color: Colors.grey[600], fontSize: 13)),
                const SizedBox(height: 16),
                FilledButton(
                  onPressed: () => ref.invalidate(myListingsProvider),
                  child: const Text('Try again'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ListingTile extends StatelessWidget {
  final Listing listing;
  final String statusLabel;
  final Color statusColor;
  final VoidCallback onTap;

  const _ListingTile({
    required this.listing,
    required this.statusLabel,
    required this.statusColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    String? coverUrl;
    if (listing.images.isNotEmpty) {
      final primary = listing.images.where((i) => i.isPrimary).toList();
      coverUrl = primary.isNotEmpty ? primary.first.fileUrl : listing.images.first.fileUrl;
    }

    final priceFmt = NumberFormat.currency(symbol: '\$', decimalDigits: 0);

    return Material(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(16),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: coverUrl != null
                    ? CachedNetworkImage(
                        imageUrl: coverUrl,
                        width: 88,
                        height: 88,
                        fit: BoxFit.cover,
                        placeholder: (context, url) => Container(
                          width: 88,
                          height: 88,
                          color: AppColors.surfaceVariant,
                          child: const Center(child: SizedBox(width: 22, height: 22, child: CircularProgressIndicator(strokeWidth: 2))),
                        ),
                        errorWidget: (context, url, error) => Container(
                          width: 88,
                          height: 88,
                          color: AppColors.surfaceVariant,
                          child: const Icon(Icons.home_work_outlined, color: AppColors.textSecondary),
                        ),
                      )
                    : Container(
                        width: 88,
                        height: 88,
                        color: AppColors.surfaceVariant,
                        child: const Icon(Icons.photo_outlined, color: AppColors.textSecondary),
                      ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      listing.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15, color: AppColors.textPrimary),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      listing.city,
                      style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: statusColor.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            statusLabel,
                            style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: statusColor),
                          ),
                        ),
                        const Spacer(),
                        Text(
                          priceFmt.format(listing.price),
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: AppColors.primary),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, color: AppColors.textSecondary),
            ],
          ),
        ),
      ),
    );
  }
}
