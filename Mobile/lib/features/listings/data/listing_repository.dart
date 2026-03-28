import 'package:dio/dio.dart';
import '../../../core/api/api_client.dart';
import '../../../models/listing.dart';
import '../../../models/paginated_response.dart';

class ListingRepository {
  final Dio dio;

  ListingRepository(this.dio);

  Future<PaginatedResponse<Listing>> getListings({
    int limit = 20,
    int offset = 0,
    String? q,
    int? categoryId,
    String? city,
    double? minPrice,
    double? maxPrice,
    String? sort,
  }) async {
    final Map<String, dynamic> queryParams = {
      'limit': limit,
      'offset': offset,
      if (q != null) 'q': q,
      if (categoryId != null) 'category_id': categoryId,
      if (city != null) 'city': city,
      if (minPrice != null) 'min_price': minPrice,
      if (maxPrice != null) 'max_price': maxPrice,
      if (sort != null) 'sort': sort,
    };

    final response = await dio.get('/listings', queryParameters: queryParams);
    
    return PaginatedResponse<Listing>.fromJson(
      response.data,
      (json) => Listing.fromJson(json),
    );
  }

  // Other endpoints: GET by ID, POST, PATCH
}
