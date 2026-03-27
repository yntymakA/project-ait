from sqlalchemy.orm import Session
from fastapi import HTTPException
from app.repositories import listing_repo, category_repo
from app.schemas.listing import ListingCreate, ListingUpdate
from app.models.sql_models.user import User
from app.models.sql_models.listing import Listing

def create_listing(db: Session, owner: User, data: ListingCreate) -> Listing:
    # Verify category exists
    category = category_repo.get_category_by_id(db, data.category_id)
    if not category:
        raise HTTPException(status_code=400, detail="Invalid category_id")
    
    return listing_repo.create_listing(db, owner_id=owner.id, **data.model_dump())

def get_listing(db: Session, listing_id: int) -> Listing:
    listing = listing_repo.get_listing(db, listing_id)
    if not listing:
        raise HTTPException(status_code=404, detail="Listing not found")
    return listing

def update_listing(db: Session, listing_id: int, owner: User, data: ListingUpdate) -> Listing:
    listing = get_listing(db, listing_id)
    
    # Optional: we might allow admins to update ANY listing, but for now strict ownership
    if listing.owner_id != owner.id:
        raise HTTPException(status_code=403, detail="Not authorized to edit this listing")
    
    update_data = data.model_dump(exclude_unset=True)
    if not update_data:
        return listing

    if "category_id" in update_data:
        category = category_repo.get_category_by_id(db, update_data["category_id"])
        if not category:
            raise HTTPException(status_code=400, detail="Invalid category_id")

    return listing_repo.update_listing(db, listing, update_data)
