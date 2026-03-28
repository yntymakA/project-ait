import 'package:dio/dio.dart';
import '../../../core/api/api_client.dart';
import '../../../models/listing.dart';
import '../../../models/paginated_response.dart';

class FavoriteRepository {
  final Dio dio;

  FavoriteRepository(this.dio);

  Future<PaginatedResponse<Listing>> getFavorites({int limit = 20, int offset = 0}) async {
    final response = await dio.get('/favorites', queryParameters: {
      'limit': limit,
      'offset': offset,
    });
    
    return PaginatedResponse<Listing>.fromJson(
      response.data,
      (json) => Listing.fromJson(json),
    );
  }

  Future<void> toggleFavorite(int listingId) async {
    // Note: In the backend, the endpoint accepts listing_id as query param or body?
    // Let's assume POST /favorites/{id} or POST /favorites with body.
    // Documentation says POST /favorites
    // Body: { "listing_id": int }
    await dio.post('/favorites', data: {'listing_id': listingId});
  }
}
