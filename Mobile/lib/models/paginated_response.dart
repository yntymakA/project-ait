// In a real project you'd use Freezed + json_serializable
// For simplicity we'll write it manually here.

class PaginatedResponse<T> {
  final List<T> items;
  final int total;
  final int limit;
  final int offset;

  PaginatedResponse({
    required this.items,
    required this.total,
    required this.limit,
    required this.offset,
  });

  factory PaginatedResponse.fromJson(
    Map<String, dynamic> json,
    T Function(Map<String, dynamic>) fromJsonT,
  ) {
    return PaginatedResponse<T>(
      items: (json['items'] as List).map((e) => fromJsonT(e as Map<String, dynamic>)).toList(),
      total: json['total'] as int,
      limit: json['limit'] as int,
      offset: json['offset'] as int,
    );
  }

  int get totalPages => (total / limit).ceil();
  bool get hasMore => offset + limit < total;
  int get currentPage => (offset / limit).floor() + 1;
}
