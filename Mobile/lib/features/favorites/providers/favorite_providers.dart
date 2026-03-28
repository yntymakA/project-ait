import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../listings/data/models/listing.dart';
import '../data/repositories/favorite_repository.dart';

// --- Repository ---
final favoriteRepositoryProvider = Provider<FavoriteRepository>((ref) {
  return FavoriteRepository();
});

// --- State Class for Pagination ---
class FavoritesState {
  final List<Listing> listings;
  final int offset;
  final bool hasMore;
  final bool isLoadingMore;

  const FavoritesState({
    required this.listings,
    required this.offset,
    required this.hasMore,
    required this.isLoadingMore,
  });

  FavoritesState copyWith({
    List<Listing>? listings,
    int? offset,
    bool? hasMore,
    bool? isLoadingMore,
  }) {
    return FavoritesState(
      listings: listings ?? this.listings,
      offset: offset ?? this.offset,
      hasMore: hasMore ?? this.hasMore,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
    );
  }
}

// --- Notifier for Paginated Favorites ---
class FavoritesListNotifier extends AsyncNotifier<FavoritesState> {
  static const int _limit = 20;

  FavoriteRepository get _repository => ref.read(favoriteRepositoryProvider);

  @override
  Future<FavoritesState> build() async {
    return _fetchInitialPage();
  }

  Future<FavoritesState> _fetchInitialPage() async {
    final response = await _repository.getFavorites(limit: _limit, offset: 0);
    
    // Auto-update the favored IDs list when we fetch favorites
    final ids = response.items.map((e) => e.id).toSet();
    ref.read(favoriteIdsProvider.notifier).addIds(ids);

    return FavoritesState(
      listings: response.items,
      offset: _limit,
      hasMore: response.items.length == _limit,
      isLoadingMore: false,
    );
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _fetchInitialPage());
  }

  Future<void> loadMore() async {
    final currentState = state.value;
    if (currentState == null || currentState.isLoadingMore || !currentState.hasMore) return;

    state = AsyncValue.data(currentState.copyWith(isLoadingMore: true));

    try {
      final response = await _repository.getFavorites(limit: _limit, offset: currentState.offset);
      
      final ids = response.items.map((e) => e.id).toSet();
      ref.read(favoriteIdsProvider.notifier).addIds(ids);

      state = AsyncValue.data(
        FavoritesState(
          listings: [...currentState.listings, ...response.items],
          offset: currentState.offset + _limit,
          hasMore: response.items.length == _limit,
          isLoadingMore: false,
        ),
      );
    } catch (e) {
      state = AsyncValue.data(currentState.copyWith(isLoadingMore: false));
    }
  }

  // Remove securely from UI if unfavorited via card
  void removeListingFromUI(int id) {
    if (state.value == null) return;
    final newList = state.value!.listings.where((e) => e.id != id).toList();
    state = AsyncValue.data(state.value!.copyWith(listings: newList));
  }
}

final favoritesListProvider = AsyncNotifierProvider<FavoritesListNotifier, FavoritesState>(
  FavoritesListNotifier.new,
);

// --- Notifier for Optimistic Favorites UI Toggling ---
class FavoriteIdsNotifier extends Notifier<Set<int>> {
  @override
  Set<int> build() {
    return {};
  }

  void addIds(Set<int> ids) {
    state = {...state, ...ids};
  }

  Future<void> toggleFavorite(int listingId) async {
    final repo = ref.read(favoriteRepositoryProvider);
    final isCurrentlyFavorited = state.contains(listingId);

    // Optimistically update UI
    if (isCurrentlyFavorited) {
      state = {...state}..remove(listingId);
    } else {
      state = {...state, listingId};
    }

    try {
      if (isCurrentlyFavorited) {
        await repo.removeFavorite(listingId);
        // Sync with the infinite scroll list so it vanishes from the Favorites tab
        ref.read(favoritesListProvider.notifier).removeListingFromUI(listingId);
      } else {
        await repo.addFavorite(listingId);
        // Refresh the list slightly later or rely on the user pulling to refresh in Tab
      }
    } catch (e) {
      // Revert if API fails
      if (isCurrentlyFavorited) {
        state = {...state, listingId};
      } else {
        state = {...state}..remove(listingId);
      }
    }
  }
}

final favoriteIdsProvider = NotifierProvider<FavoriteIdsNotifier, Set<int>>(
  FavoriteIdsNotifier.new,
);
