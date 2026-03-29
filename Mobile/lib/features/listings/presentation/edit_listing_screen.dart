import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:latlong2/latlong.dart';

import '../../../core/api/api_client.dart';
import '../../../core/maps/listing_location_picker.dart';
import '../../../core/theme/app_colors.dart';
import '../data/models/listing.dart';
import '../providers/listing_providers.dart';
import '../providers/my_listings_provider.dart';

class _EditCategoryOption {
  final int id;
  final String name;
  final int depth;

  const _EditCategoryOption({
    required this.id,
    required this.name,
    required this.depth,
  });

  String get label => '${'  ' * depth}$name';
}

List<_EditCategoryOption> _parseEditCategoryOptions(List<dynamic> raw) {
  final options = <_EditCategoryOption>[];

  void walk(List<dynamic> nodes, int depth) {
    for (final node in nodes) {
      if (node is! Map) continue;
      final map = Map<String, dynamic>.from(node);
      final idValue = map['id'];
      final nameValue = map['name'];
      if (idValue is! num || nameValue is! String || nameValue.trim().isEmpty) {
        continue;
      }

      options.add(
        _EditCategoryOption(
          id: idValue.toInt(),
          name: nameValue,
          depth: depth,
        ),
      );

      final children = map['children'];
      if (children is List) {
        walk(children, depth + 1);
      }
    }
  }

  walk(raw, 0);
  return options;
}

final editCategoryOptionsProvider =
    FutureProvider.autoDispose<List<_EditCategoryOption>>((ref) async {
  final response = await dioClient.get<List<dynamic>>('/categories');
  final data = response.data ?? const <dynamic>[];
  return _parseEditCategoryOptions(data);
});

class EditListingScreen extends ConsumerStatefulWidget {
  final int listingId;

  const EditListingScreen({super.key, required this.listingId});

  @override
  ConsumerState<EditListingScreen> createState() => _EditListingScreenState();
}

class _EditListingScreenState extends ConsumerState<EditListingScreen> {
  final _formKey = GlobalKey<FormState>();

  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _priceController = TextEditingController();
  final _cityController = TextEditingController();

  double? _latitude;
  double? _longitude;
  bool _isNegotiable = false;
  int? _selectedCategoryId;
  bool _saving = false;
  int? _seededForId;

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _cityController.dispose();
    super.dispose();
  }

  void _seedFrom(Listing l) {
    if (_seededForId == l.id) return;
    _seededForId = l.id;
    _titleController.text = l.title;
    _descriptionController.text = l.description;
    _priceController.text = l.price.toString();
    _cityController.text = l.city;
    _selectedCategoryId = l.categoryId;
    _isNegotiable = l.isNegotiable;
    _latitude = l.latitude;
    _longitude = l.longitude;
  }

  bool get _hasLocation => _latitude != null && _longitude != null;

  Future<void> _save(Listing listing) async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final price = double.tryParse(_priceController.text.trim());
    if (price == null) return;

    if (_selectedCategoryId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a category'), backgroundColor: AppColors.error),
      );
      return;
    }

    setState(() => _saving = true);

    try {
      final repo = ref.read(listingRepositoryProvider);
      final hadPin = listing.latitude != null && listing.longitude != null;
      final clearCoordinates = hadPin && !_hasLocation;

      await repo.updateListing(
        id: listing.id,
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
        price: price,
        currency: listing.currency,
        city: _cityController.text.trim(),
        categoryId: _selectedCategoryId,
        isNegotiable: _isNegotiable,
        latitude: _latitude,
        longitude: _longitude,
        clearCoordinates: clearCoordinates,
      );

      if (!mounted) return;

      ref.invalidate(myListingsProvider);
      ref.invalidate(listingDetailProvider(listing.id));
      ref.read(feedListingsProvider.notifier).refresh();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Listing updated'), backgroundColor: AppColors.success),
      );
      context.pop();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Update failed: $e'), backgroundColor: AppColors.error),
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final async = ref.watch(listingDetailProvider(widget.listingId));
    final categoriesAsync = ref.watch(editCategoryOptionsProvider);

    return async.when(
      data: (listing) {
        _seedFrom(listing);
        return Scaffold(
          backgroundColor: AppColors.background,
          appBar: AppBar(
            title: const Text('Edit listing', style: TextStyle(fontWeight: FontWeight.bold)),
            backgroundColor: AppColors.surface,
            foregroundColor: AppColors.textPrimary,
            elevation: 0,
          ),
          body: Form(
            key: _formKey,
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
              children: [
                if (listing.images.isNotEmpty) ...[
                  Text('Photos', style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  SizedBox(
                    height: 96,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: listing.images.length,
                      separatorBuilder: (context, index) => const SizedBox(width: 10),
                      itemBuilder: (context, i) {
                        final img = listing.images[i];
                        return ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: AspectRatio(
                            aspectRatio: 1,
                            child: CachedNetworkImage(
                              imageUrl: img.fileUrl,
                              fit: BoxFit.cover,
                              placeholder: (context, url) => Container(color: AppColors.surfaceVariant),
                              errorWidget: (context, url, error) => Container(
                                color: AppColors.surfaceVariant,
                                child: const Icon(Icons.broken_image_outlined),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Images cannot be changed here. Edit updates title, description, price, and location.',
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 20),
                ],
                TextFormField(
                  controller: _titleController,
                  decoration: _fieldDeco('Title'),
                  maxLength: 120,
                  validator: (v) => (v == null || v.trim().isEmpty) ? 'Required' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _descriptionController,
                  decoration: _fieldDeco('Description'),
                  maxLines: 5,
                  maxLength: 2000,
                  validator: (v) => (v == null || v.trim().isEmpty) ? 'Required' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _priceController,
                  decoration: _fieldDeco('Price').copyWith(prefixText: '\$ '),
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9.]'))],
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) return 'Required';
                    if (double.tryParse(v.trim()) == null) return 'Invalid number';
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _cityController,
                  decoration: _fieldDeco('City'),
                  validator: (v) => (v == null || v.trim().isEmpty) ? 'Required' : null,
                ),
                const SizedBox(height: 16),
                _buildCategoryField(categoriesAsync),
                const SizedBox(height: 12),
                InkWell(
                  onTap: () => setState(() => _isNegotiable = !_isNegotiable),
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    decoration: BoxDecoration(
                      color: _isNegotiable ? AppColors.primary.withValues(alpha: 0.08) : AppColors.surfaceVariant,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: _isNegotiable ? AppColors.primary : AppColors.border,
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          _isNegotiable ? Icons.check_circle : Icons.radio_button_unchecked,
                          color: _isNegotiable ? AppColors.primary : AppColors.grey400,
                          size: 22,
                        ),
                        const SizedBox(width: 10),
                        const Expanded(
                          child: Text(
                            'Price is negotiable',
                            style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Text('Location on map', style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                ListingLocationPicker(
                  latitude: _latitude,
                  longitude: _longitude,
                  height: 220,
                  onLocationChanged: (LatLng point) {
                    setState(() {
                      _latitude = point.latitude;
                      _longitude = point.longitude;
                    });
                  },
                ),
                if (_hasLocation) ...[
                  const SizedBox(height: 8),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: TextButton.icon(
                      onPressed: () {
                        setState(() {
                          _latitude = null;
                          _longitude = null;
                        });
                      },
                      icon: const Icon(Icons.clear, size: 18),
                      label: const Text('Clear pin'),
                    ),
                  ),
                ],
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: FilledButton(
                    onPressed: _saving ? null : () => _save(listing),
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                    ),
                    child: _saving
                        ? const SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.white),
                          )
                        : const Text('Save changes', style: TextStyle(fontWeight: FontWeight.w700)),
                  ),
                ),
              ],
            ),
          ),
        );
      },
      loading: () => const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (e, _) => Scaffold(
        appBar: AppBar(title: const Text('Edit listing')),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, size: 48, color: AppColors.error),
                const SizedBox(height: 12),
                Text('$e', textAlign: TextAlign.center),
                const SizedBox(height: 16),
                FilledButton(onPressed: () => context.pop(), child: const Text('Go back')),
              ],
            ),
          ),
        ),
      ),
    );
  }

  InputDecoration _fieldDeco(String label) {
    return InputDecoration(
      labelText: label,
      filled: true,
      fillColor: AppColors.surfaceVariant,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
      ),
    );
  }

  Widget _buildCategoryField(AsyncValue<List<_EditCategoryOption>> categoriesAsync) {
    return categoriesAsync.when(
      loading: () => const LinearProgressIndicator(minHeight: 2),
      error: (_, __) => Row(
        children: [
          const Expanded(
            child: Text(
              'Failed to load categories',
              style: TextStyle(color: AppColors.error),
            ),
          ),
          TextButton(
            onPressed: () => ref.invalidate(editCategoryOptionsProvider),
            child: const Text('Retry'),
          ),
        ],
      ),
      data: (categories) {
        final hasSelected = _selectedCategoryId != null &&
            categories.any((c) => c.id == _selectedCategoryId);

        return DropdownButtonFormField<int>(
          initialValue: hasSelected ? _selectedCategoryId : null,
          items: categories
              .map(
                (c) => DropdownMenuItem<int>(
                  value: c.id,
                  child: Text(c.label, overflow: TextOverflow.ellipsis),
                ),
              )
              .toList(),
          isExpanded: true,
          onChanged: categories.isEmpty
              ? null
              : (value) {
                  setState(() => _selectedCategoryId = value);
                },
          validator: (_) => _selectedCategoryId == null ? 'Required' : null,
          decoration: _fieldDeco('Category'),
        );
      },
    );
  }
}
