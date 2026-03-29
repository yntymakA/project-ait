from pydantic import BaseModel, ConfigDict
from decimal import Decimal
from datetime import datetime
from typing import Optional
from app.models.enums import PromotionTypeEnum, PromotionStatusEnum


class PromotionPackageResponse(BaseModel):
    id: int
    name: str
    promotion_type: PromotionTypeEnum
    duration_days: int
    price: Decimal
    is_active: bool

    model_config = ConfigDict(from_attributes=True)


class PromotionPackageListResponse(BaseModel):
    items: list[PromotionPackageResponse]


class PurchasePromotionRequest(BaseModel):
    listing_id: Optional[int] = None
    package_id: int
    target_city: Optional[str] = None
    target_category_id: Optional[int] = None


class PromotionResponse(BaseModel):
    id: int
    listing_id: Optional[int] = None
    user_id: int
    package_id: Optional[int] = None
    promotion_type: PromotionTypeEnum
    status: PromotionStatusEnum
    purchased_price: Decimal
    starts_at: Optional[datetime] = None
    ends_at: Optional[datetime] = None
    created_at: datetime

    model_config = ConfigDict(from_attributes=True)
