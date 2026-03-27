from pydantic import BaseModel, ConfigDict
from datetime import datetime
from typing import Optional, Any
from app.models.enums import NotificationTypeEnum


class NotificationResponse(BaseModel):
    id: int
    user_id: int
    type: NotificationTypeEnum
    is_read: bool
    payload: Optional[dict[str, Any]] = None
    created_at: datetime

    model_config = ConfigDict(from_attributes=True)


class NotificationListResponse(BaseModel):
    items: list[NotificationResponse]
    unread_count: int
    total: int
    limit: int
    offset: int


class DeviceTokenRequest(BaseModel):
    fcm_token: str
