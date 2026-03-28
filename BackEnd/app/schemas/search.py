from fastapi import Query
from typing import Optional
from app.models.enums import ModerationStatusEnum


class ListingSearchParams:
    """
    FastAPI dependency class that groups all listing search/filter query parameters.
    Usage in router: `params: ListingSearchParams = Depends()`
    """
    def __init__(
        self,
        page: int = Query(1, ge=1, description="Page number"),
        page_size: int = Query(20, ge=1, le=100, description="Items per page"),
        q: Optional[str] = Query(None, description="Search keyword in title/description"),
        category_id: Optional[int] = Query(None, description="Filter by category ID"),
        city: Optional[str] = Query(None, description="Filter by city/location"),
        min_price: Optional[float] = Query(None, ge=0, description="Minimum price"),
        max_price: Optional[float] = Query(None, ge=0, description="Maximum price"),
        sort: str = Query(
            "newest",
            regex="^(newest|oldest|price_asc|price_desc)$",
            description="Sort order: newest, oldest, price_asc, price_desc",
        ),
    ):
        self.page = page
        self.page_size = page_size
        self.q = q
        self.category_id = category_id
        self.city = city
        self.min_price = min_price
        self.max_price = max_price
        self.sort = sort

        # Internal field — set by the backend, not by the user's query string
        self.status: Optional[ModerationStatusEnum] = None
