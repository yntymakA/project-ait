from sqlalchemy.orm import Session
from fastapi import HTTPException, UploadFile
from typing import List
from app.repositories import listing_repo, category_repo
from app.schemas.listing import ListingCreate, ListingUpdate
from app.models.sql_models.user import User
from app.models.sql_models.listing import Listing
from app.models.enums import ListingStatusEnum
from app.services.storage import upload_service
from app.repositories.listing_repo import MAX_LISTING_IMAGES

def create_listing(db: Session, owner: User, data: ListingCreate, files: list[UploadFile]) -> Listing:
    """Create a new listing with 1 to 3 images uploaded in one atomic call."""
    if not (1 <= len(files) <= MAX_LISTING_IMAGES):
        raise HTTPException(
            status_code=400,
            detail=f"Between 1 and {MAX_LISTING_IMAGES} images are required to create a listing."
        )

    # Verify category exists
    category = category_repo.get_category_by_id(db, data.category_id)
    if not category:
        raise HTTPException(status_code=400, detail="Invalid category_id")

    # Create the listing record first
    listing = listing_repo.create_listing(db, owner_id=owner.id, **data.model_dump())

    # Upload all 3 images and attach them; first image is the primary cover
    for index, file in enumerate(files):
        public_url = upload_service.upload_image_to_firebase(file)
        is_primary = (index == 0)
        listing_repo.add_listing_image(db, listing.id, public_url, is_primary=is_primary)

    # Reload to include the freshly created images in the response
    db.refresh(listing)
    return listing

def get_listing(db: Session, listing_id: int) -> Listing:
    listing = listing_repo.get_listing(db, listing_id)
    if not listing:
        raise HTTPException(status_code=404, detail="Listing not found")
    return listing

def update_listing(db: Session, listing_id: int, owner: User, data: ListingUpdate) -> Listing:
    listing = get_listing(db, listing_id)

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

def set_primary_image(db: Session, listing_id: int, image_id: int, owner: User):
    listing = get_listing(db, listing_id)
    if listing.owner_id != owner.id:
        raise HTTPException(status_code=403, detail="Not authorized")

    if not listing_repo.set_primary_image(db, listing_id, image_id):
        raise HTTPException(status_code=404, detail="Image not found")
    return True


def deactivate_listing(db: Session, listing_id: int, owner: User) -> Listing:
    listing = get_listing(db, listing_id)

    if listing.owner_id != owner.id:
        raise HTTPException(status_code=403, detail="Not authorized to deactivate this listing")

    if listing.status == ListingStatusEnum.archived:
        return listing

    return listing_repo.archive_listing(db, listing)
