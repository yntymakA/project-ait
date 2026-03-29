import 'package:dio/dio.dart';

import '../../../../core/api/api_client.dart';
import '../../../../core/models/paginated_response.dart';
import '../../../listings/data/models/listing.dart';
import '../models/public_profile.dart';

class UserPublicRepository {
  final Dio _dio;

  UserPublicRepository({Dio? dio}) : _dio = dio ?? dioClient;

  Future<PublicProfile> getPublicProfile(int userId) async {
    final response = await _dio.get('/users/public/$userId');
    return PublicProfile.fromJson(response.data as Map<String, dynamic>);
  }

  Future<PaginatedResponse<Listing>> getUserListings({
    required int userId,
    int limit = 20,
    int offset = 0,
  }) async {
    final response = await _dio.get(
      '/users/public/$userId/listings',
      queryParameters: {
        'limit': limit,
        'offset': offset,
      },
    );

    final Map<String, dynamic> data = response.data as Map<String, dynamic>;
    final total = data['total'] as int? ?? 0;
    final page = (offset / limit).floor() + 1;
    final totalPages = total == 0 ? 1 : (total / limit).ceil();

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
}
