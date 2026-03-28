from fastapi import APIRouter, Depends, UploadFile, File, Form, Query, status
from typing import Optional
from sqlalchemy.orm import Session
from app.core.dependencies import get_db, get_current_user
from app.schemas.listing import ListingCreate, ListingUpdate, ListingResponse
from app.schemas.pagination import PaginatedResponse, create_paginated_response
from app.schemas.search import ListingSearchParams
from app.services.listing import listing_service
from app.services.search import search_service
from app.models.sql_models.user import User
from app.models.enums import ModerationStatusEnum
from app.repositories import listing_repo

router = APIRouter(prefix="/listings", tags=["Listings"])


@router.get("", response_model=PaginatedResponse[ListingResponse])
def get_listings(
    params: ListingSearchParams = Depends(),
    db: Session = Depends(get_db),
):
    """
    Public listing feed with search, filters, pricing, sorting, and pagination.
    top_feed-promoted listings always appear first.
    Filters: category, city, min price, max price.
    Sorting: newest, oldest, price_asc, price_desc.
    """
    # Public feed only shows approved listings
    params.status = ModerationStatusEnum.approved

    total, items = search_service.search_listings(db, params)
    return create_paginated_response(items, total, params.page, params.page_size)


@router.post("", response_model=ListingResponse, status_code=status.HTTP_201_CREATED)
def create_listing(
    # Listing fields as form params (because we're doing multipart upload)
    title: str = Form(...),
    description: str = Form(...),
    price: float = Form(...),
    currency: str = Form("USD"),
    city: str = Form(...),
    category_id: int = Form(...),
    is_negotiable: bool = Form(False),
    # 1 to 3 images
    image1: UploadFile = File(..., description="First image (will be set as primary/cover)"),
    image2: Optional[UploadFile] = File(None, description="Second image"),
    image3: Optional[UploadFile] = File(None, description="Third image"),
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    """Create a new real estate listing. Requires exactly 3 images uploaded as multipart form."""
    data = ListingCreate(
        title=title,
        description=description,
        price=price,
        currency=currency,
        city=city,
        category_id=category_id,
        is_negotiable=is_negotiable,
    )
    files = [f for f in [image1, image2, image3] if f is not None]
    return listing_service.create_listing(db, current_user, data, files)


@router.get("/{listing_id}", response_model=ListingResponse)
def get_listing(listing_id: int, db: Session = Depends(get_db)):
    """Retrieve full details for a listing by ID."""
    return listing_service.get_listing(db, listing_id)


@router.patch("/{listing_id}", response_model=ListingResponse)
def update_listing(
    listing_id: int,
    data: ListingUpdate,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    """Update details of an owned listing."""
    return listing_service.update_listing(db, listing_id, current_user, data)


@router.patch("/{listing_id}/images/{image_id}/primary")
def set_primary_image(
    listing_id: int,
    image_id: int,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    """Set one of the 3 listing images as the primary/cover photo."""
    listing_service.set_primary_image(db, listing_id, image_id, current_user)
    return {"message": "Primary image updated successfully"}
