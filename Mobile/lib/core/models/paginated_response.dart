import 'package:json_annotation/json_annotation.dart';

part 'paginated_response.g.dart';

@JsonSerializable(genericArgumentFactories: true)
class PaginatedResponse<T> {
  final List<T> items;
  final int page;
  
  @JsonKey(name: 'page_size')
  final int pageSize;
  
  @JsonKey(name: 'total_items')
  final int totalItems;
  
  @JsonKey(name: 'total_pages')
  final int totalPages;

  PaginatedResponse({
    required this.items,
    required this.page,
    required this.pageSize,
    required this.totalItems,
    required this.totalPages,
  });

  factory PaginatedResponse.fromJson(
    Map<String, dynamic> json,
    T Function(Object?) fromJsonT,
  ) =>
      _$PaginatedResponseFromJson(json, fromJsonT);

  Map<String, dynamic> toJson(Object Function(T) toJsonT) =>
      _$PaginatedResponseToJson(this, toJsonT);
}
