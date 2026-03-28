import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/models/listing.dart';
import '../data/repositories/listing_repository.dart';

// --- Repository ---
final listingRepositoryProvider = Provider<ListingRepository>((ref) {
  return ListingRepository();
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
  static const int _pageSize = 20;

  ListingRepository get _repository => ref.read(listingRepositoryProvider);

  @override
  Future<FeedState> build() async {
    return _fetchInitialPage();
  }

  Future<FeedState> _fetchInitialPage() async {
    final response = await _repository.getListings(page: 1, pageSize: _pageSize);
    
    return FeedState(
      listings: response.items,
      currentPage: 1,
      hasMore: response.page < response.totalPages,
      isLoadingMore: false,
    );
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _fetchInitialPage());
  }

  Future<void> loadMore() async {
    final currentState = state.value;
    // Don't load if currently loading, errored, or no more items
    if (currentState == null || currentState.isLoadingMore || !currentState.hasMore) return;

    // Set loading indicator
    state = AsyncValue.data(currentState.copyWith(isLoadingMore: true));

    try {
      final nextPage = currentState.currentPage + 1;
      final response = await _repository.getListings(page: nextPage, pageSize: _pageSize);

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
    }
  }
}

final feedListingsProvider = AsyncNotifierProvider<FeedListingsNotifier, FeedState>(
  FeedListingsNotifier.new,
);
