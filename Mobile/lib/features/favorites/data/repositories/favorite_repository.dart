import 'package:dio/dio.dart';
import '../../../../core/api/api_client.dart';
import '../../../../core/models/paginated_response.dart';
import '../../../listings/data/models/listing.dart';

class FavoriteRepository {
  final Dio _dio;

  FavoriteRepository({Dio? dio}) : _dio = dio ?? dioClient;

  // Uses FastAPI's default paginated dictionary but normalize it for app's PaginatedResponse model
  Future<PaginatedResponse<Listing>> getFavorites({
    int limit = 20,
    int offset = 0,
  }) async {
    final response = await _dio.get(
      '/favorites',
      queryParameters: {
        'limit': limit,
        'offset': offset,
      },
    );

    final Map<String, dynamic> data = response.data;
    final total = data['total'] as int? ?? 0;
    final page = (offset / limit).floor() + 1;
    final totalPages = (total / limit).ceil();

    final normalizedData = {
      'items': data['items'],
      'page': page,
      'page_size': limit,
      'total_items': total,
      'total_pages': totalPages < 1 ? 1 : totalPages,
    };

    return PaginatedResponse<Listing>.fromJson(
      normalizedData,
      (json) => Listing.fromJson(json as Map<String, dynamic>),
    );
  }

  Future<void> addFavorite(int listingId) async {
    await _dio.post('/favorites/$listingId');
  }

  Future<void> removeFavorite(int listingId) async {
    await _dio.delete('/favorites/$listingId');
  }
}
