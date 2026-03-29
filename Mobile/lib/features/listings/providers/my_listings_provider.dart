import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/models/listing.dart';
import '../data/repositories/listing_repository.dart';
import '../../../core/models/paginated_response.dart';
import 'listing_providers.dart';

final myListingsProvider =
    FutureProvider.autoDispose<PaginatedResponse<Listing>>((ref) async {
  final repo = ref.watch(listingRepositoryProvider);
  return repo.getMyListings(page: 1, pageSize: 50);
});
