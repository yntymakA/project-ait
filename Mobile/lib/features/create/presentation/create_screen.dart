import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../../listings/data/repositories/listing_repository.dart';
import '../../listings/providers/listing_providers.dart';

// ---------------------------------------------------------------------------
// State
// ---------------------------------------------------------------------------

class CreateListingState {
  final List<File?> images; // always length 3
  final bool isSubmitting;
  final String? errorMessage;
  final bool isSuccess;

  const CreateListingState({
    required this.images,
    this.isSubmitting = false,
    this.errorMessage,
    this.isSuccess = false,
  });

  CreateListingState copyWith({
    List<File?>? images,
    bool? isSubmitting,
    String? errorMessage,
    bool clearError = false,
    bool? isSuccess,
  }) {
    return CreateListingState(
      images: images ?? this.images,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      isSuccess: isSuccess ?? this.isSuccess,
    );
  }
}

// ---------------------------------------------------------------------------
// Notifier
// ---------------------------------------------------------------------------

class CreateListingNotifier extends Notifier<CreateListingState> {
  final _picker = ImagePicker();

  @override
  CreateListingState build() {
    return const CreateListingState(images: [null, null, null]);
  }

  Future<void> pickImage(int slot) async {
    final xFile = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
    );
    if (xFile == null) return;

    final updated = List<File?>.from(state.images);
    updated[slot] = File(xFile.path);
    state = state.copyWith(images: updated, clearError: true);
  }

  void removeImage(int slot) {
    final updated = List<File?>.from(state.images);
    updated[slot] = null;
    state = state.copyWith(images: updated, clearError: true);
  }

  Future<bool> submit({
    required String title,
    required String description,
    required double price,
    required String currency,
    required String city,
    required int categoryId,
    required bool isNegotiable,
  }) async {
    // Validate at least the cover image is chosen
    if (state.images[0] == null) {
      state = state.copyWith(errorMessage: 'Please select a cover photo.');
      return false;
    }

    state = state.copyWith(isSubmitting: true, clearError: true);

    try {
      final repo = ref.read(listingRepositoryProvider);
      await repo.createListing(
        title: title,
        description: description,
        price: price,
        currency: currency,
        city: city,
        categoryId: categoryId,
        isNegotiable: isNegotiable,
        image1Path: state.images[0]!.path,
        image2Path: state.images[1]?.path,
        image3Path: state.images[2]?.path,
      );

      // Refresh the feed so the new listing appears
      ref.read(feedListingsProvider.notifier).refresh();

      state = state.copyWith(isSubmitting: false, isSuccess: true);
      return true;
    } catch (e) {
      state = state.copyWith(
        isSubmitting: false,
        errorMessage: 'Failed to create listing. Please try again.',
      );
      return false;
    }
  }

  void reset() {
    state = const CreateListingState(images: [null, null, null]);
  }
}

final createListingProvider =
    NotifierProvider<CreateListingNotifier, CreateListingState>(
  CreateListingNotifier.new,
);

// Hardcoded values per requirements
const _kDefaultCategoryId = 1;
const _kDefaultCurrency = 'USD';

// ---------------------------------------------------------------------------
// Screen
// ---------------------------------------------------------------------------

class CreateScreen extends ConsumerStatefulWidget {
  const CreateScreen({super.key});

  @override
  ConsumerState<CreateScreen> createState() => _CreateScreenState();
}

class _CreateScreenState extends ConsumerState<CreateScreen> {
  final _formKey = GlobalKey<FormState>();

  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _priceController = TextEditingController();
  final _cityController = TextEditingController();

  static const String _currency = 'USD';
  static const int _categoryId = 1;
  bool _isNegotiable = false;

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _cityController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final price = double.tryParse(_priceController.text.trim());
    if (price == null) return;

    final success = await ref.read(createListingProvider.notifier).submit(
          title: _titleController.text.trim(),
          description: _descriptionController.text.trim(),
          price: price,
          currency: _currency,
          city: _cityController.text.trim(),
          categoryId: _categoryId,
          isNegotiable: _isNegotiable,
        );

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('🎉 Listing submitted for review!'),
          backgroundColor: AppColors.success,
          behavior: SnackBarBehavior.floating,
        ),
      );
      ref.read(createListingProvider.notifier).reset();
      _titleController.clear();
      _descriptionController.clear();
      _priceController.clear();
      _cityController.clear();
      setState(() {
        _isNegotiable = false;
      });
      context.go('/feed');
    }
  }

  @override
  Widget build(BuildContext context) {
    final createState = ref.watch(createListingProvider);

    // Show error messages as snackbars
    ref.listen<CreateListingState>(createListingProvider, (prev, next) {
      if (next.errorMessage != null &&
          next.errorMessage != prev?.errorMessage) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.errorMessage!),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    });

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Form(
        key: _formKey,
        child: CustomScrollView(
          slivers: [
            // ---- Header ----
            SliverToBoxAdapter(
              child: _buildHeader(context),
            ),
            // ---- Photos Section ----
            SliverToBoxAdapter(
              child: _SectionCard(
                title: 'Photos',
                subtitle: 'Select up to 3 photos. First is required.',
                icon: Icons.photo_library_outlined,
                child: _PhotoGrid(images: createState.images),
              ),
            ),
            // ---- Details Section ----
            SliverToBoxAdapter(
              child: _SectionCard(
                title: 'Details',
                icon: Icons.info_outline,
                child: Column(
                  children: [
                    _buildTextField(
                      controller: _titleController,
                      label: 'Title',
                      hint: 'e.g. 2-room apartment in city center',
                      maxLength: 120,
                      validator: (v) => (v == null || v.trim().isEmpty)
                          ? 'Title is required'
                          : null,
                    ),
                    const SizedBox(height: 16),
                    _buildTextField(
                      controller: _descriptionController,
                      label: 'Description',
                      hint: 'Describe your listing…',
                      maxLines: 5,
                      maxLength: 2000,
                      validator: (v) => (v == null || v.trim().isEmpty)
                          ? 'Description is required'
                          : null,
                    ),
                  ],
                ),
              ),
            ),
            // ---- Pricing Section ----
            SliverToBoxAdapter(
              child: _SectionCard(
                title: 'Price',
                icon: Icons.monetization_on_outlined,
                child: Column(
                  children: [
                    _buildTextField(
                      controller: _priceController,
                      label: 'Price (USD)',
                      hint: '0',
                      prefixText: '\$ ',
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                      ],
                      validator: (v) {
                        if (v == null || v.trim().isEmpty) {
                          return 'Price is required';
                        }
                        if (double.tryParse(v.trim()) == null) {
                          return 'Enter a valid number';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    _buildTextField(
                      controller: _cityController,
                      label: 'City',
                      hint: 'e.g. Bishkek',
                      validator: (v) => (v == null || v.trim().isEmpty)
                          ? 'City is required'
                          : null,
                    ),
                    const SizedBox(height: 12),
                    _buildNegotiableToggle(),
                  ],
                ),
              ),
            ),
            // ---- Submit Button ----
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
                child: _SubmitButton(
                  isLoading: createState.isSubmitting,
                  onPressed: _submit,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.primary, AppColors.primaryLight],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(28)),
      ),
      child: SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.add_business,
                      color: Colors.white, size: 24),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Text(
                    'New Listing',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      letterSpacing: -0.5,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Fill in the details below and add 3 photos to post your listing.',
              style: TextStyle(
                color: Colors.white.withOpacity(0.85),
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    int maxLines = 1,
    int? maxLength,
    TextInputType? keyboardType,
    List<TextInputFormatter>? inputFormatters,
    String? Function(String?)? validator,
    String? prefixText,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      maxLength: maxLength,
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixText: prefixText,
        filled: true,
        fillColor: AppColors.surfaceVariant,
        counterText: '',
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.error),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.error, width: 1.5),
        ),
      ),
    );
  }

  // Removed Category and Currency dropdowns per requirements

  Widget _buildNegotiableToggle() {
    return InkWell(
      onTap: () => setState(() => _isNegotiable = !_isNegotiable),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: _isNegotiable
              ? AppColors.primary.withOpacity(0.08)
              : AppColors.surfaceVariant,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: _isNegotiable ? AppColors.primary : AppColors.border,
          ),
        ),
        child: Row(
          children: [
            Icon(
              _isNegotiable
                  ? Icons.check_circle
                  : Icons.radio_button_unchecked,
              color: _isNegotiable ? AppColors.primary : AppColors.grey400,
              size: 22,
            ),
            const SizedBox(width: 10),
            const Expanded(
              child: Text(
                'Price is negotiable',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Photo Grid Widget
// ---------------------------------------------------------------------------

class _PhotoGrid extends ConsumerWidget {
  final List<File?> images;

  const _PhotoGrid({required this.images});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: List.generate(3, (i) {
            return Expanded(
              child: Padding(
                padding: EdgeInsets.only(right: i < 2 ? 10 : 0),
                child: _PhotoSlot(
                  file: images[i],
                  slot: i,
                  isPrimary: i == 0,
                ),
              ),
            );
          }),
        ),
        const SizedBox(height: 8),
        Text(
          'First photo will be the cover image.',
          style: TextStyle(
            fontSize: 12,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }
}

class _PhotoSlot extends ConsumerWidget {
  final File? file;
  final int slot;
  final bool isPrimary;

  const _PhotoSlot({
    required this.file,
    required this.slot,
    this.isPrimary = false,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifier = ref.read(createListingProvider.notifier);

    return GestureDetector(
      onTap: () => notifier.pickImage(slot),
      child: AspectRatio(
        aspectRatio: 1,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          decoration: BoxDecoration(
            color: file != null
                ? Colors.transparent
                : AppColors.surfaceVariant,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: file != null ? AppColors.primary : AppColors.border,
              width: file != null ? 2 : 1,
            ),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(13),
            child: file != null
                ? Stack(
                    fit: StackFit.expand,
                    children: [
                      Image.file(file!, fit: BoxFit.cover),
                      if (isPrimary)
                        Positioned(
                          top: 4,
                          left: 4,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: AppColors.primary,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: const Text(
                              'Cover',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      Positioned(
                        top: 4,
                        right: 4,
                        child: GestureDetector(
                          onTap: () => notifier.removeImage(slot),
                          child: Container(
                            padding: const EdgeInsets.all(3),
                            decoration: const BoxDecoration(
                              color: Colors.black54,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.close,
                                color: Colors.white, size: 14),
                          ),
                        ),
                      ),
                    ],
                  )
                : Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        isPrimary
                            ? Icons.add_a_photo_outlined
                            : Icons.add_photo_alternate_outlined,
                        color: AppColors.primary,
                        size: 26,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        isPrimary ? 'Cover' : 'Photo ${slot + 1}',
                        style: const TextStyle(
                          fontSize: 11,
                          color: AppColors.textSecondary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Section Card Widget
// ---------------------------------------------------------------------------

class _SectionCard extends StatelessWidget {
  final String title;
  final String? subtitle;
  final IconData icon;
  final Widget child;

  const _SectionCard({
    required this.title,
    this.subtitle,
    required this.icon,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.blackWithOpacity(0.05),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: AppColors.primaryWithOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: AppColors.primary, size: 18),
              ),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  if (subtitle != null)
                    Text(
                      subtitle!,
                      style: const TextStyle(
                        fontSize: 11,
                        color: AppColors.textSecondary,
                      ),
                    ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Divider(height: 1, color: AppColors.divider),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Submit Button
// ---------------------------------------------------------------------------

class _SubmitButton extends StatelessWidget {
  final bool isLoading;
  final VoidCallback onPressed;

  const _SubmitButton({
    required this.isLoading,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 54,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          gradient: isLoading
              ? null
              : const LinearGradient(
                  colors: [AppColors.primary, AppColors.primaryLight],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                ),
          color: isLoading ? AppColors.grey300 : null,
          borderRadius: BorderRadius.circular(16),
          boxShadow: isLoading
              ? []
              : [
                  BoxShadow(
                    color: AppColors.primaryWithOpacity(0.4),
                    blurRadius: 12,
                    offset: const Offset(0, 6),
                  ),
                ],
        ),
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.transparent,
            shadowColor: Colors.transparent,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          ),
          onPressed: isLoading ? null : onPressed,
          child: isLoading
              ? const SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.5,
                    color: Colors.white,
                  ),
                )
              : const Text(
                  'Post Listing',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.3,
                  ),
                ),
        ),
      ),
    );
  }
}
