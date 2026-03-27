from fastapi import APIRouter, Depends
from sqlalchemy.orm import Session
from app.core.dependencies import get_db, get_current_user
from app.schemas.listing import ListingCreate, ListingUpdate, ListingResponse
from app.services import listing_service
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
