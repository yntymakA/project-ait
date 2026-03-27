"""
Notification service — In-App (DB) + FCM Push.

Other services call `send_notification()` to create both:
  1. A persistent DB record (visible via GET /notifications)
  2. An instant FCM push to the user's device (if fcm_token is set)
"""
import logging
from sqlalchemy.orm import Session
from app.models.sql_models.user import User
from app.models.enums import NotificationTypeEnum
from app.repositories import notification_repo, user_repo

logger = logging.getLogger(__name__)

# ──────────────────────────────────────────────────
# FCM Push helper
# ──────────────────────────────────────────────────

# Человекочитаемые заголовки для каждого типа уведомления
_TITLES = {
    NotificationTypeEnum.listing_approved: "Listing Approved ✅",
    NotificationTypeEnum.listing_rejected: "Listing Rejected ❌",
    NotificationTypeEnum.new_message: "New Message 💬",
    NotificationTypeEnum.payment_success: "Payment Successful 💰",
    NotificationTypeEnum.promotion_activated: "Promotion Activated 🚀",
    NotificationTypeEnum.promotion_expired: "Promotion Expired ⏰",
}


def _try_send_push(fcm_token: str | None, notif_type: NotificationTypeEnum, payload: dict | None):
    """Best-effort FCM push. Never raises — failures are logged and ignored."""
    if not fcm_token:
        return

    try:
        from firebase_admin import messaging

        title = _TITLES.get(notif_type, "Notification")
        # Формируем тело из payload или фолбэк
        body = ""
        if payload:
            body = payload.get("message", payload.get("title", str(notif_type.value)))
        else:
            body = str(notif_type.value)

        message = messaging.Message(
            notification=messaging.Notification(title=title, body=body),
            data={k: str(v) for k, v in (payload or {}).items()},  # FCM data must be str values
            token=fcm_token,
        )
        messaging.send(message)
        logger.info(f"FCM push sent to token ...{fcm_token[-8:]}")
    except Exception as e:
        # Не ломаем основной флоу если push не прошёл
        logger.warning(f"FCM push failed: {e}")


# ──────────────────────────────────────────────────
# Public API (called by other services)
# ──────────────────────────────────────────────────

def send_notification(
    db: Session,
    user_id: int,
    type: NotificationTypeEnum,
    payload: dict | None = None,
):
    """Create an in-app notification + send FCM push."""
    # 1. Save to DB
    notif = notification_repo.create_notification(db, user_id, type, payload)
    db.commit()
    db.refresh(notif)

    # 2. Send FCM push (best-effort, non-blocking)
    user = db.query(User).filter(User.id == user_id).first()
    fcm_token = getattr(user, "fcm_token", None) if user else None
    _try_send_push(fcm_token, type, payload)

    return notif


def get_notifications(db: Session, user_id: int, limit: int, offset: int):
    total, items = notification_repo.get_user_notifications(db, user_id, skip=offset, limit=limit)
    unread = notification_repo.count_unread(db, user_id)
    return {
        "items": items,
        "unread_count": unread,
        "total": total,
        "limit": limit,
        "offset": offset,
    }


def mark_as_read(db: Session, notification_id: int, user_id: int):
    notif = notification_repo.mark_as_read(db, notification_id, user_id)
    return notif


def mark_all_as_read(db: Session, user_id: int):
    count = notification_repo.mark_all_as_read(db, user_id)
    return {"marked_read": count}


def save_device_token(db: Session, user: User, fcm_token: str):
    """Save or update the user's FCM device token."""
    user.fcm_token = fcm_token
    db.commit()
    db.refresh(user)
    return {"status": "ok"}
