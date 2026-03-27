from fastapi import APIRouter, Depends, UploadFile, File, HTTPException, status
from sqlalchemy.orm import Session
from app.core.dependencies import get_db, get_current_user
from app.schemas.listing import ListingCreate, ListingUpdate, ListingResponse, ListingImageResponse
from app.services.listing import listing_service
from app.services.storage import upload_service
from app.models.sql_models.user import User

router = APIRouter(prefix="/listings", tags=["Listings"])

@router.post("", response_model=ListingResponse, status_code=status.HTTP_201_CREATED)
def create_listing(
    data: ListingCreate,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    """Create a new real estate listing."""
    return listing_service.create_listing(db, current_user, data)

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

@router.post("/{listing_id}/images", response_model=ListingImageResponse, status_code=status.HTTP_201_CREATED)
def upload_listing_image(
    listing_id: int,
    file: UploadFile = File(...),
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    """Uploads an image to Firebase Storage and attaches it to the listing."""
    return listing_service.upload_and_add_listing_image(db, listing_id, current_user, file)

@router.delete("/{listing_id}/images/{image_id}", status_code=status.HTTP_204_NO_CONTENT)
def delete_listing_image(
    listing_id: int,
    image_id: int,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    """Delete an image from a listing."""
    listing_service.delete_listing_image(db, listing_id, image_id, current_user)
    return None

@router.patch("/{listing_id}/images/{image_id}/primary")
def set_primary_image(
    listing_id: int,
    image_id: int,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    """Set a specific image as the primary/cover photo."""
    listing_service.set_primary_image(db, listing_id, image_id, current_user)
    return {"message": "Primary image updated successfully"}
