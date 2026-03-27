from fastapi import HTTPException
from sqlalchemy.orm import Session
from sqlalchemy.exc import IntegrityError
from app.repositories import favorite_repo, listing_repo
from app.models.sql_models.user import User
from app.models.sql_models.favorite import Favorite
from app.models.sql_models.listing import Listing

def add_favorite_service(db: Session, user: User, listing_id: int) -> Favorite:
    # Check if listing exists
    listing = listing_repo.get_listing(db, listing_id)
    if not listing:
        raise HTTPException(status_code=404, detail="Listing not found")
        
    # Check if already in favorites
    existing = favorite_repo.get_favorite(db, user.id, listing_id)
    if existing:
        raise HTTPException(status_code=409, detail="Listing is already in your favorites")
        
    try:
        return favorite_repo.add_favorite(db, user.id, listing_id)
    except IntegrityError:
        db.rollback()
        raise HTTPException(status_code=409, detail="Listing is already in your favorites")

def remove_favorite_service(db: Session, user: User, listing_id: int) -> dict:
    success = favorite_repo.remove_favorite(db, user.id, listing_id)
    if not success:
        raise HTTPException(status_code=404, detail="Listing not found in your favorites")
    return {"message": "Listing removed from favorites successfully"}

def get_user_favorites_service(db: Session, user: User, limit: int, offset: int) -> dict:
    total, listings = favorite_repo.get_user_favorites(db, user.id, offset, limit)
    return {
        "items": listings,
        "total": total,
        "limit": limit,
        "offset": offset
    }
