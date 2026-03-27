from fastapi import APIRouter, Depends, UploadFile, File, HTTPException, status
from sqlalchemy.orm import Session
from app.core.dependencies import get_db, get_current_user
from app.schemas.listing import ListingCreate, ListingUpdate, ListingResponse, ListingImageResponse
from app.services import listing_service, upload_service
from app.models.sql_models.user import User

router = APIRouter(prefix="/listings", tags=["Listings"])

@router.post("", response_model=ListingResponse, status_code=201)
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

@router.post("/{listing_id}/images", response_model=ListingImageResponse, status_code=201)
def upload_listing_image(
    listing_id: int,
    file: UploadFile = File(...),
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    """Uploads an image to Firebase Storage and attaches it to the listing."""
    # 1. Verify ownership
    listing = listing_service.get_listing(db, listing_id)
    if listing.owner_id != current_user.id:
        raise HTTPException(status_code=403, detail="Not authorized to edit this listing")
    
    # 2. Upload to Firebase
    public_url = upload_service.upload_image_to_firebase(file)
    
    # 3. Save to database
    # If it's the first image, make it primary automatically
    is_first = len(listing.images) == 0
    from app.repositories import listing_repo
    img = listing_repo.add_listing_image(db, listing_id, public_url, is_primary=is_first)
    return img

@router.delete("/{listing_id}/images/{image_id}", status_code=status.HTTP_204_NO_CONTENT)
def delete_listing_image(
    listing_id: int,
    image_id: int,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    """Delete an image from a listing."""
    listing = listing_service.get_listing(db, listing_id)
    if listing.owner_id != current_user.id:
        raise HTTPException(status_code=403, detail="Not authorized")
    
    from app.repositories import listing_repo
    if not listing_repo.delete_listing_image(db, image_id):
        raise HTTPException(status_code=404, detail="Image not found")
    return None

@router.patch("/{listing_id}/images/{image_id}/primary")
def set_primary_image(
    listing_id: int,
    image_id: int,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    """Set a specific image as the primary/cover photo."""
    listing = listing_service.get_listing(db, listing_id)
    if listing.owner_id != current_user.id:
        raise HTTPException(status_code=403, detail="Not authorized")
        
    from app.repositories import listing_repo
    if not listing_repo.set_primary_image(db, listing_id, image_id):
        raise HTTPException(status_code=404, detail="Image not found")
        
    return {"message": "Primary image updated successfully"}
