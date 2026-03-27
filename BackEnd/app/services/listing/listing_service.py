from sqlalchemy.orm import Session
from fastapi import HTTPException, UploadFile
from app.repositories import listing_repo, category_repo
from app.schemas.listing import ListingCreate, ListingUpdate
from app.models.sql_models.user import User
from app.models.sql_models.listing import Listing
from app.services.storage import upload_service

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

def upload_and_add_listing_image(db: Session, listing_id: int, owner: User, file: UploadFile):
    listing = get_listing(db, listing_id)
    if listing.owner_id != owner.id:
        raise HTTPException(status_code=403, detail="Not authorized to edit this listing")
    
    public_url = upload_service.upload_image_to_firebase(file)
    
    is_first = len(listing.images) == 0
    return listing_repo.add_listing_image(db, listing_id, public_url, is_primary=is_first)

def delete_listing_image(db: Session, listing_id: int, image_id: int, owner: User):
    listing = get_listing(db, listing_id)
    if listing.owner_id != owner.id:
        raise HTTPException(status_code=403, detail="Not authorized")
    
    if not listing_repo.delete_listing_image(db, image_id):
        raise HTTPException(status_code=404, detail="Image not found")
    return True

def set_primary_image(db: Session, listing_id: int, image_id: int, owner: User):
    listing = get_listing(db, listing_id)
    if listing.owner_id != owner.id:
        raise HTTPException(status_code=403, detail="Not authorized")
        
    if not listing_repo.set_primary_image(db, listing_id, image_id):
        raise HTTPException(status_code=404, detail="Image not found")
    return True
