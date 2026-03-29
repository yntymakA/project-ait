from typing import List

from pydantic import BaseModel, ConfigDict

from app.schemas.listing import ListingResponse


class FavoriteResponse(BaseModel):
    id: int
    user_id: int
    listing_id: int

    model_config = ConfigDict(from_attributes=True)


class FavoritesListResponse(BaseModel):
    """Paginated favorites — same keys as before; items are full listing payloads with images."""

    items: List[ListingResponse]
    total: int
    limit: int
    offset: int
