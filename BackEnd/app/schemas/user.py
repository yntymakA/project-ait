from pydantic import BaseModel, EmailStr
from datetime import datetime
from typing import Optional
from app.models.enums import RoleEnum, UserStatusEnum

class UserBase(BaseModel):
    full_name: str
    email: EmailStr
    phone: Optional[str] = None
    bio: Optional[str] = None
    city: Optional[str] = None
    preferred_language: str = "ru"

class UserUpdate(BaseModel):
    full_name: Optional[str] = None
    phone: Optional[str] = None
    bio: Optional[str] = None
    city: Optional[str] = None
    preferred_language: Optional[str] = None

class UserResponse(UserBase):
    id: int
    firebase_uid: str
    role: RoleEnum
    status: UserStatusEnum
    profile_image_url: Optional[str] = None
    last_seen_at: Optional[datetime] = None
    created_at: datetime
    
    # We ignore balance here from public response usually, but you can include it if needed
    
    class Config:
        from_attributes = True

class UserSyncResponse(UserResponse):
    """Response returned when syncing a firebase token"""
    pass


class PublicUserResponse(BaseModel):
    """Public profile — no email, phone, or firebase_uid exposed."""
    id: int
    full_name: str
    profile_image_url: Optional[str] = None
    city: Optional[str] = None
    member_since: datetime
    active_listing_count: int

    class Config:
        from_attributes = True
