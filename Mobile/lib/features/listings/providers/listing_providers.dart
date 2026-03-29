import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/models/listing.dart';
import '../data/repositories/listing_repository.dart';
import 'feed_filters_provider.dart';

// --- Repository ---
final listingRepositoryProvider = Provider<ListingRepository>((ref) {
  return ListingRepository();
});

final listingDetailProvider = FutureProvider.family<Listing, int>((ref, id) async {
  return ref.read(listingRepositoryProvider).getListingById(id);
});

// --- State Class ---
class FeedState {
  final List<Listing> listings;
  final int currentPage;
  final bool hasMore;
  final bool isLoadingMore;

  const FeedState({
    required this.listings,
    required this.currentPage,
    required this.hasMore,
    required this.isLoadingMore,
  });

  FeedState copyWith({
    List<Listing>? listings,
    int? currentPage,
    bool? hasMore,
    bool? isLoadingMore,
  }) {
    return FeedState(
      listings: listings ?? this.listings,
      currentPage: currentPage ?? this.currentPage,
      hasMore: hasMore ?? this.hasMore,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
    );
  }
}

// --- Notifier ---
class FeedListingsNotifier extends AsyncNotifier<FeedState> {
  // Smaller chunks improve perceived speed and reduce failures on slow networks.
  static const int _pageSize = 10;
  bool _isFetchingPage = false;

  ListingRepository get _repository => ref.read(listingRepositoryProvider);

  @override
  Future<FeedState> build() async {
    final filters = ref.watch(feedFiltersProvider);
    return _fetchInitialPage(filters);
  }

  Future<FeedState> _fetchInitialPage(FeedFilters filters) async {
    final response = await _repository.getListings(
      page: 1, 
      pageSize: _pageSize,
      query: filters.query,
      categoryId: filters.categoryId,
      city: filters.city,
      minPrice: filters.minPrice,
      maxPrice: filters.maxPrice,
      sort: filters.sort,
    );
    
    return FeedState(
      listings: response.items,
      currentPage: 1,
      hasMore: response.page < response.totalPages,
      isLoadingMore: false,
    );
  }

  Future<void> refresh() async {
    _isFetchingPage = false;
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _fetchInitialPage(ref.read(feedFiltersProvider)));
  }

  Future<void> loadMore() async {
    final currentState = state.value;
    // Don't load if currently loading, errored, or no more items
    if (currentState == null || currentState.isLoadingMore || !currentState.hasMore || _isFetchingPage) {
      return;
    }
    _isFetchingPage = true;

    // Set loading indicator
    state = AsyncValue.data(currentState.copyWith(isLoadingMore: true));

    try {
      final nextPage = currentState.currentPage + 1;
      final filters = ref.read(feedFiltersProvider);
      final response = await _repository.getListings(
        page: nextPage, 
        pageSize: _pageSize,
        query: filters.query,
        categoryId: filters.categoryId,
        city: filters.city,
        minPrice: filters.minPrice,
        maxPrice: filters.maxPrice,
        sort: filters.sort,
      );

      state = AsyncValue.data(
        FeedState(
          listings: [...currentState.listings, ...response.items],
          currentPage: nextPage,
          hasMore: response.page < response.totalPages,
          isLoadingMore: false,
        ),
      );
    } catch (e) {
      // Revert loading state, throw to allow UI to handle error if needed
      state = AsyncValue.data(currentState.copyWith(isLoadingMore: false));
      // Re-throwing the error using state = AsyncError will destroy the existing list UI,
      // so in infinite scroll it's better to catch it here or show a toast.
    } finally {
      _isFetchingPage = false;
    }
  }
}

final feedListingsProvider = AsyncNotifierProvider<FeedListingsNotifier, FeedState>(
  FeedListingsNotifier.new,
);
