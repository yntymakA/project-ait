import 'user.dart';

class ListingImage {
  final int id;
  final String fileUrl;
  final bool isPrimary;
  final int orderIndex;

  ListingImage({
    required this.id,
    required this.fileUrl,
    required this.isPrimary,
    required this.orderIndex,
  });

  factory ListingImage.fromJson(Map<String, dynamic> json) {
    return ListingImage(
      id: json['id'] as int,
      fileUrl: json['file_url'] as String,
      isPrimary: json['is_primary'] as bool? ?? false,
      orderIndex: json['order_index'] as int? ?? 0,
    );
  }
}

class CategoryBrief {
  final int id;
  final String name;

  CategoryBrief({required this.id, required this.name});

  factory CategoryBrief.fromJson(Map<String, dynamic> json) {
    return CategoryBrief(
      id: json['id'] as int,
      name: json['name'] as String,
    );
  }
}

class Listing {
  final int id;
  final String title;
  final String description;
  final double price;
  final String currency;
  final String city;
  final String status;
  final String moderationStatus;
  final String promotionStatus;
  final int viewCount;
  final bool isNegotiable;
  final DateTime createdAt;
  final User? owner;
  final CategoryBrief? category;
  final List<ListingImage> images;

  Listing({
    required this.id,
    required this.title,
    required this.description,
    required this.price,
    required this.currency,
    required this.city,
    required this.status,
    required this.moderationStatus,
    required this.promotionStatus,
    required this.viewCount,
    required this.isNegotiable,
    required this.createdAt,
    this.owner,
    this.category,
    this.images = const [],
  });

  factory Listing.fromJson(Map<String, dynamic> json) {
    return Listing(
      id: json['id'] as int,
      title: json['title'] as String,
      description: json['description'] as String,
      price: double.tryParse(json['price'].toString()) ?? 0.0,
      currency: json['currency'] as String,
      city: json['city'] as String,
      status: json['status'] as String,
      moderationStatus: json['moderation_status'] as String,
      promotionStatus: json['promotion_status'] as String,
      viewCount: json['view_count'] as int? ?? 0,
      isNegotiable: json['is_negotiable'] as bool? ?? false,
      createdAt: DateTime.parse(json['created_at'] as String),
      owner: json['owner'] != null ? User.fromJson(json['owner'] as Map<String, dynamic>) : null,
      category: json['category'] != null ? CategoryBrief.fromJson(json['category'] as Map<String, dynamic>) : null,
      images: json['images'] != null
          ? (json['images'] as List).map((i) => ListingImage.fromJson(i as Map<String, dynamic>)).toList()
          : [],
    );
  }

  String? get primaryImageUrl {
    if (images.isEmpty) return null;
    try {
      return images.firstWhere((img) => img.isPrimary).fileUrl;
    } catch (_) {
      return images.first.fileUrl; // fallback if no primary explicitly set
    }
  }
}
