from pydantic import BaseModel, EmailStr
from datetime import datetime
from typing import List, Optional

from app.models.enums import RoleEnum, UserStatusEnum
from app.schemas.listing import ListingResponse

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
    
    class Config:
        from_attributes = True


class UserMeResponse(UserResponse):
    """Current user only: wallet + featured (VIP) badge derived from active promotions."""

    has_featured_badge: bool = False
    # float serializes reliably in JSON for all clients (Decimal can become string in some stacks)
    balance: float = 0.0

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
    has_featured_badge: bool = False

    class Config:
        from_attributes = True


class UserPublicListingsResponse(BaseModel):
    """Paginated approved listings for a seller — full [ListingResponse] with images."""

    items: List[ListingResponse]
    total: int
    limit: int
    offset: int
