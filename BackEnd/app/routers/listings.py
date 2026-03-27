from fastapi import APIRouter, Depends, UploadFile, File, Form, status
from sqlalchemy.orm import Session
from app.core.dependencies import get_db, get_current_user
from app.schemas.listing import ListingCreate, ListingUpdate, ListingResponse
from app.services.listing import listing_service
from app.models.sql_models.user import User

router = APIRouter(prefix="/listings", tags=["Listings"])

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
    # Exactly 3 required images
    image1: UploadFile = File(..., description="First image (will be set as primary/cover)"),
    image2: UploadFile = File(..., description="Second image"),
    image3: UploadFile = File(..., description="Third image"),
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
    files = [image1, image2, image3]
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
