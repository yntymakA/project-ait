import 'package:json_annotation/json_annotation.dart';

part 'listing.g.dart';

@JsonSerializable()
class ListingImage {
  final int id;
  
  @JsonKey(name: 'file_url')
  final String fileUrl;
  
  @JsonKey(name: 'is_primary')
  final bool isPrimary;
  
  @JsonKey(name: 'order_index')
  final int orderIndex;

  ListingImage({
    required this.id,
    required this.fileUrl,
    required this.isPrimary,
    required this.orderIndex,
  });

  factory ListingImage.fromJson(Map<String, dynamic> json) =>
      _$ListingImageFromJson(json);

  Map<String, dynamic> toJson() => _$ListingImageToJson(this);
}

@JsonSerializable()
class Listing {
  final int id;
  
  @JsonKey(name: 'owner_id')
  final int ownerId;
  
  final String title;
  final String description;
  final double price;
  final String currency;
  final String city;

  /// WGS84 decimal degrees from map/OSM; both null if not pinned.
  final double? latitude;
  final double? longitude;
  
  @JsonKey(name: 'category_id')
  final int categoryId;
  
  @JsonKey(name: 'is_negotiable')
  final bool isNegotiable;
  
  final String status;
  
  @JsonKey(name: 'moderation_status')
  final String moderationStatus;
  
  @JsonKey(name: 'promotion_status')
  final String promotionStatus;
  
  @JsonKey(name: 'view_count')
  final int viewCount;
  
  @JsonKey(name: 'created_at')
  final DateTime createdAt;
  
  final List<ListingImage> images;

  Listing({
    required this.id,
    required this.ownerId,
    required this.title,
    required this.description,
    required this.price,
    required this.currency,
    required this.city,
    this.latitude,
    this.longitude,
    required this.categoryId,
    required this.isNegotiable,
    required this.status,
    required this.moderationStatus,
    required this.promotionStatus,
    required this.viewCount,
    required this.createdAt,
    this.images = const [],
  });

  factory Listing.fromJson(Map<String, dynamic> json) =>
      _$ListingFromJson(json);

  Map<String, dynamic> toJson() => _$ListingToJson(this);
}
