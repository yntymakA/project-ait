from typing import Generic, TypeVar, List
from pydantic import BaseModel
import math

T = TypeVar('T')

class PaginatedResponse(BaseModel, Generic[T]):
    """
    Standard HTTP response format for paginated data.
    """
    items: List[T]
    page: int
    page_size: int
    total_items: int
    total_pages: int

    class Config:
        from_attributes = True

def create_paginated_response(items: List[T], total_items: int, page: int, page_size: int) -> PaginatedResponse[T]:
    """Helper function to cleanly generate the paginated response model."""
    total_pages = math.ceil(total_items / page_size) if page_size > 0 else 0
    return PaginatedResponse(
        items=items,
        page=page,
        page_size=page_size,
        total_items=total_items,
        total_pages=total_pages
    )
