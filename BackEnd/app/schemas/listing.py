from pydantic import BaseModel, ConfigDict, model_validator
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
    # OSM / map picker: decimal degrees (WGS84). Omit both if no pin yet.
    latitude: Optional[float] = None
    longitude: Optional[float] = None

    @model_validator(mode="after")
    def coordinates_both_or_neither(self) -> "ListingCreate":
        lat, lon = self.latitude, self.longitude
        if (lat is None) != (lon is None):
            raise ValueError("latitude and longitude must be provided together, or both omitted")
        if lat is not None:
            if lat < -90 or lat > 90:
                raise ValueError("latitude must be between -90 and 90")
            if lon is not None and (lon < -180 or lon > 180):
                raise ValueError("longitude must be between -180 and 180")
        return self


class ListingUpdate(BaseModel):
    title: Optional[str] = None
    description: Optional[str] = None
    price: Optional[float] = None
    currency: Optional[str] = None
    city: Optional[str] = None
    category_id: Optional[int] = None
    is_negotiable: Optional[bool] = None
    latitude: Optional[float] = None
    longitude: Optional[float] = None

    @model_validator(mode="after")
    def coordinates_both_or_neither(self) -> "ListingUpdate":
        lat, lon = self.latitude, self.longitude
        if (lat is None) != (lon is None):
            raise ValueError("latitude and longitude must be provided together, or both omitted")
        if lat is not None:
            if lat < -90 or lat > 90:
                raise ValueError("latitude must be between -90 and 90")
            if lon is not None and (lon < -180 or lon > 180):
                raise ValueError("longitude must be between -180 and 180")
        return self

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
