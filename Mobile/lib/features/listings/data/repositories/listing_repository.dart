import 'package:dio/dio.dart';
import '../../../../core/api/api_client.dart';
import '../../../../core/models/paginated_response.dart';
import '../models/listing.dart';

class ListingRepository {
  final Dio _dio;

  ListingRepository({Dio? dio}) : _dio = dio ?? dioClient;

  Future<PaginatedResponse<Listing>> getListings({
    int page = 1,
    int pageSize = 20,
    String? query,
    int? categoryId,
    String? city,
    double? minPrice,
    double? maxPrice,
    String? sort,
  }) async {
    final queryParams = <String, dynamic>{
      'page': page,
      'page_size': pageSize,
      if (query?.isNotEmpty ?? false) 'q': query,
      if (categoryId != null) 'category_id': categoryId,
      if (city?.isNotEmpty ?? false) 'city': city,
      if (minPrice != null) 'min_price': minPrice,
      if (maxPrice != null) 'max_price': maxPrice,
      if (sort?.isNotEmpty ?? false) 'sort': sort,
    };

    final response = await _dio.get('/listings', queryParameters: queryParams);

    // The backend PaginatedResponse requires mapping the nested items
    return PaginatedResponse<Listing>.fromJson(
      response.data as Map<String, dynamic>,
      (json) => Listing.fromJson(json as Map<String, dynamic>),
    );
  }

  Future<Listing> getListingById(int id) async {
    final response = await _dio.get('/listings/$id');
    return Listing.fromJson(response.data as Map<String, dynamic>);
  }
}
