from pydantic import BaseModel, ConfigDict
from datetime import datetime
from typing import Optional, List
from app.models.enums import ListingStatusEnum, ModerationStatusEnum, PromotionStatusEnum

class ListingImageResponse(BaseModel):
    id: int
    file_url: str
    is_primary: bool
    order_index: int
    model_config = ConfigDict(from_attributes=True)

class ListingCreate(BaseModel):
    title: str
    description: str
    price: float
    currency: str = "USD"
    city: str
    category_id: int
    is_negotiable: bool = False

class ListingUpdate(BaseModel):
    title: Optional[str] = None
    description: Optional[str] = None
    price: Optional[float] = None
    currency: Optional[str] = None
    city: Optional[str] = None
    category_id: Optional[int] = None
    is_negotiable: Optional[bool] = None

class ListingResponse(ListingCreate):
    id: int
    owner_id: int
    status: ListingStatusEnum
    moderation_status: ModerationStatusEnum
    promotion_status: PromotionStatusEnum
    view_count: int
    created_at: datetime
    images: List[ListingImageResponse] = []
    
    model_config = ConfigDict(from_attributes=True)
