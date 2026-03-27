from fastapi import APIRouter, Depends, Query, HTTPException, status
from sqlalchemy.orm import Session
from app.core.dependencies import get_db, get_current_user
from app.models.sql_models.user import User
from app.schemas.notification import (
    NotificationListResponse,
    NotificationResponse,
    DeviceTokenRequest,
)
from app.services.notification import notification_service

router = APIRouter(prefix="/notifications", tags=["Notifications"])


@router.get("", response_model=NotificationListResponse)
def get_notifications(
    limit: int = Query(20, ge=1, le=100),
    offset: int = Query(0, ge=0),
    db: Session = Depends(get_db),
    user: User = Depends(get_current_user),
):
    """List notifications for the current user with unread count."""
    return notification_service.get_notifications(db, user.id, limit, offset)


@router.patch(
    "/{notification_id}/read",
    response_model=NotificationResponse,
    summary="Mark a single notification as read",
)
def mark_notification_read(
    notification_id: int,
    db: Session = Depends(get_db),
    user: User = Depends(get_current_user),
):
    notif = notification_service.mark_as_read(db, notification_id, user.id)
    if not notif:
        raise HTTPException(status_code=404, detail="Notification not found")
    return notif


@router.patch("/read-all", summary="Mark all notifications as read")
def mark_all_read(
    db: Session = Depends(get_db),
    user: User = Depends(get_current_user),
):
    return notification_service.mark_all_as_read(db, user.id)


@router.post("/device-token", summary="Save FCM device token for push notifications")
def save_device_token(
    data: DeviceTokenRequest,
    db: Session = Depends(get_db),
    user: User = Depends(get_current_user),
):
    """Call this after login to register the device for push notifications."""
    return notification_service.save_device_token(db, user, data.fcm_token)
