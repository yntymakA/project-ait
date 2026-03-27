from fastapi import APIRouter, Depends, Query, status
from sqlalchemy.orm import Session
from app.core.dependencies import get_db, get_current_user
from app.services.favorites import favorite_service
from app.models.sql_models.user import User

router = APIRouter(prefix="/favorites", tags=["Favorites"])

@router.post("/{listing_id}", status_code=status.HTTP_201_CREATED)
def add_favorite(
    listing_id: int,
    db: Session = Depends(get_db),
    user: User = Depends(get_current_user)
):
    """Add a listing to favorites."""
    # We return a simple message, but under the hood the service enforces rules.
    fav = favorite_service.add_favorite_service(db, user, listing_id)
    return {"message": "Listing added to favorites successfully"}

@router.delete("/{listing_id}", status_code=status.HTTP_204_NO_CONTENT)
def remove_favorite(
    listing_id: int,
    db: Session = Depends(get_db),
    user: User = Depends(get_current_user)
):
    """Remove a listing from favorites."""
    favorite_service.remove_favorite_service(db, user, listing_id)
    return

@router.get("")
def get_favorites(
    limit: int = Query(20, ge=1, le=100),
    offset: int = Query(0, ge=0),
    db: Session = Depends(get_db),
    user: User = Depends(get_current_user)
):
    """Get the current user's paginated list of favorite listings."""
    # It returns a dict that will be serialized via FastAPI's default JSON encoder
    # which matches the format `{ items: [...Listings], total, limit, offset }`
    return favorite_service.get_user_favorites_service(db, user, limit, offset)
