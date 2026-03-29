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

  /// Creates a new listing with 1 to 3 images via multipart/form-data.
  Future<Listing> createListing({
    required String title,
    required String description,
    required double price,
    required String currency,
    required String city,
    required int categoryId,
    required bool isNegotiable,
    required String image1Path,
    String? image2Path,
    String? image3Path,
    double? latitude,
    double? longitude,
  }) async {
    final formMap = <String, dynamic>{
      'title': title,
      'description': description,
      'price': price,
      'currency': currency,
      'city': city,
      'category_id': categoryId,
      'is_negotiable': isNegotiable,
      'image1': await MultipartFile.fromFile(image1Path, filename: 'image1.jpg'),
    };

    if (latitude != null && longitude != null) {
      formMap['latitude'] = latitude;
      formMap['longitude'] = longitude;
    }

    if (image2Path != null) {
      formMap['image2'] = await MultipartFile.fromFile(image2Path, filename: 'image2.jpg');
    }
    if (image3Path != null) {
      formMap['image3'] = await MultipartFile.fromFile(image3Path, filename: 'image3.jpg');
    }

    final formData = FormData.fromMap(formMap);

    final response = await _dio.post(
      '/listings',
      data: formData,
      options: Options(contentType: 'multipart/form-data'),
    );
    return Listing.fromJson(response.data as Map<String, dynamic>);
  }

  /// Authenticated: current user's listings (all moderation states).
  Future<PaginatedResponse<Listing>> getMyListings({
    int page = 1,
    int pageSize = 50,
  }) async {
    final response = await _dio.get(
      '/listings/me',
      queryParameters: {
        'page': page,
        'page_size': pageSize,
      },
    );
    return PaginatedResponse<Listing>.fromJson(
      response.data as Map<String, dynamic>,
      (json) => Listing.fromJson(json as Map<String, dynamic>),
    );
  }

  /// PATCH — update text fields and optional map pin (images unchanged).
  Future<Listing> updateListing({
    required int id,
    String? title,
    String? description,
    double? price,
    String? currency,
    String? city,
    int? categoryId,
    bool? isNegotiable,
    double? latitude,
    double? longitude,
    bool clearCoordinates = false,
  }) async {
    final data = <String, dynamic>{};
    if (title != null) data['title'] = title;
    if (description != null) data['description'] = description;
    if (price != null) data['price'] = price;
    if (currency != null) data['currency'] = currency;
    if (city != null) data['city'] = city;
    if (categoryId != null) data['category_id'] = categoryId;
    if (isNegotiable != null) data['is_negotiable'] = isNegotiable;
    if (clearCoordinates) {
      data['latitude'] = null;
      data['longitude'] = null;
    } else if (latitude != null && longitude != null) {
      data['latitude'] = latitude;
      data['longitude'] = longitude;
    }

    final response = await _dio.patch('/listings/$id', data: data);
    return Listing.fromJson(response.data as Map<String, dynamic>);
  }

  Future<Listing> deactivateListing(int id) async {
    final response = await _dio.patch('/listings/$id/deactivate');
    return Listing.fromJson(response.data as Map<String, dynamic>);
  }
}

