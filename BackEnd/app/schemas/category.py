from pydantic import BaseModel
from typing import Optional, List

class CategoryBase(BaseModel):
    name: str
    slug: str
    parent_id: Optional[int] = None
    display_order: int = 0

class CategoryResponse(CategoryBase):
    id: int
    is_active: bool

    class Config:
        from_attributes = True

class CategoryTreeResponse(CategoryResponse):
    children: List['CategoryTreeResponse'] = []
