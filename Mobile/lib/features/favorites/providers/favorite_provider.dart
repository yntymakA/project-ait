import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/api/api_client.dart';
import '../../../models/listing.dart';
import '../../../models/paginated_response.dart';
import '../data/favorite_repository.dart';

final favoriteRepositoryProvider = Provider<FavoriteRepository>((ref) {
  return FavoriteRepository(ref.watch(dioProvider));
});

class FavoritePaginationArgs {
  final int offset;
  final int limit;

  FavoritePaginationArgs({this.offset = 0, this.limit = 20});

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FavoritePaginationArgs &&
          runtimeType == other.runtimeType &&
          offset == other.offset &&
          limit == other.limit;

  @override
  int get hashCode => offset.hashCode ^ limit.hashCode;
}

final favoritesProvider = FutureProvider.family<PaginatedResponse<Listing>, FavoritePaginationArgs>((ref, args) async {
  final repo = ref.watch(favoriteRepositoryProvider);
  return repo.getFavorites(limit: args.limit, offset: args.offset);
});
