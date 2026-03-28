import 'package:freezed_annotation/freezed_annotation.dart';

part 'notification.freezed.dart';
part 'notification.g.dart';

enum NotificationType {
  @JsonValue('listing_approved')
  listingApproved,
  @JsonValue('listing_rejected')
  listingRejected,
  @JsonValue('new_message')
  newMessage,
  @JsonValue('payment_success')
  paymentSuccess,
  @JsonValue('promotion_activated')
  promotionActivated,
  @JsonValue('promotion_expired')
  promotionExpired,
}

@freezed
abstract class NotificationModel with _$NotificationModel {
  const factory NotificationModel({
    required int id,
    required NotificationType type,
    @Default(false) bool isRead,
    Map<String, dynamic>? payload,
    required DateTime createdAt,
  }) = _NotificationModel;

  factory NotificationModel.fromJson(Map<String, dynamic> json) =>
      _$NotificationModelFromJson(json);
}

