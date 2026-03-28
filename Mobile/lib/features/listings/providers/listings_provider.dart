import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/api/api_client.dart';
import '../../../models/listing.dart';
import '../../../models/paginated_response.dart';
import '../data/listing_repository.dart';

final listingRepositoryProvider = Provider<ListingRepository>((ref) {
  return ListingRepository(ref.watch(dioProvider));
});

// A simple paginated provider approach using Riverpod 2.x AsyncNotifier
class FeedPaginationArgs {
  final int offset;
  final int limit;
  // add filters later

  FeedPaginationArgs({this.offset = 0, this.limit = 20});

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FeedPaginationArgs &&
          runtimeType == other.runtimeType &&
          offset == other.offset &&
          limit == other.limit;

  @override
  int get hashCode => offset.hashCode ^ limit.hashCode;
}

final feedProvider = FutureProvider.family<PaginatedResponse<Listing>, FeedPaginationArgs>((ref, args) async {
  final repo = ref.watch(listingRepositoryProvider);
  return repo.getListings(
    limit: args.limit,
    offset: args.offset,
  );
});
