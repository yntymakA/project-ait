// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'listing.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ListingImage _$ListingImageFromJson(Map<String, dynamic> json) => ListingImage(
  id: (json['id'] as num).toInt(),
  fileUrl: json['file_url'] as String,
  isPrimary: json['is_primary'] as bool,
  orderIndex: (json['order_index'] as num).toInt(),
);

Map<String, dynamic> _$ListingImageToJson(ListingImage instance) =>
    <String, dynamic>{
      'id': instance.id,
      'file_url': instance.fileUrl,
      'is_primary': instance.isPrimary,
      'order_index': instance.orderIndex,
    };

Listing _$ListingFromJson(Map<String, dynamic> json) => Listing(
  id: (json['id'] as num).toInt(),
  ownerId: (json['owner_id'] as num).toInt(),
  title: json['title'] as String,
  description: json['description'] as String,
  price: (json['price'] as num).toDouble(),
  currency: json['currency'] as String,
  city: json['city'] as String,
  latitude: (json['latitude'] as num?)?.toDouble(),
  longitude: (json['longitude'] as num?)?.toDouble(),
  categoryId: (json['category_id'] as num).toInt(),
  isNegotiable: json['is_negotiable'] as bool,
  status: json['status'] as String,
  moderationStatus: json['moderation_status'] as String,
  promotionStatus: json['promotion_status'] as String,
  viewCount: (json['view_count'] as num).toInt(),
  createdAt: DateTime.parse(json['created_at'] as String),
  images:
      (json['images'] as List<dynamic>?)
          ?.map((e) => ListingImage.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
);

Map<String, dynamic> _$ListingToJson(Listing instance) => <String, dynamic>{
  'id': instance.id,
  'owner_id': instance.ownerId,
  'title': instance.title,
  'description': instance.description,
  'price': instance.price,
  'currency': instance.currency,
  'city': instance.city,
  'latitude': instance.latitude,
  'longitude': instance.longitude,
  'category_id': instance.categoryId,
  'is_negotiable': instance.isNegotiable,
  'status': instance.status,
  'moderation_status': instance.moderationStatus,
  'promotion_status': instance.promotionStatus,
  'view_count': instance.viewCount,
  'created_at': instance.createdAt.toIso8601String(),
  'images': instance.images,
};
