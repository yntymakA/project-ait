from sqlalchemy.orm import Session
from sqlalchemy import func
from app.models.sql_models.listing import Listing, ListingImage

def create_listing(db: Session, owner_id: int, **kwargs) -> Listing:
    listing = Listing(owner_id=owner_id, **kwargs)
    db.add(listing)
    db.commit()
    db.refresh(listing)
    return listing

def get_listing(db: Session, listing_id: int) -> Listing | None:
    return db.query(Listing).filter(Listing.id == listing_id, Listing.deleted_at == None).first()

def update_listing(db: Session, listing: Listing, update_data: dict) -> Listing:
    for key, value in update_data.items():
        setattr(listing, key, value)
    db.commit()
    db.refresh(listing)
    return listing

def get_listings_by_owner(db: Session, owner_id: int, skip: int = 0, limit: int = 20) -> list[Listing]:
    return db.query(Listing).filter(Listing.owner_id == owner_id, Listing.deleted_at == None).offset(skip).limit(limit).all()

def add_listing_image(db: Session, listing_id: int, file_url: str, is_primary: bool = False) -> ListingImage:
    # Find current max order index
    max_order = db.query(func.max(ListingImage.order_index)).filter(ListingImage.listing_id == listing_id).scalar() or 0
    next_order = max_order + 1

    img = ListingImage(
        listing_id=listing_id,
        file_url=file_url,
        is_primary=is_primary,
        order_index=next_order
    )
    db.add(img)
    db.commit()
    db.refresh(img)
    return img

def delete_listing_image(db: Session, image_id: int) -> bool:
    img = db.query(ListingImage).filter(ListingImage.id == image_id).first()
    if img:
        db.delete(img)
        db.commit()
        return True
    return False

def set_primary_image(db: Session, listing_id: int, image_id: int) -> bool:
    # Set all to false
    db.query(ListingImage).filter(ListingImage.listing_id == listing_id).update({"is_primary": False})
    # Set target to true
    img = db.query(ListingImage).filter(ListingImage.id == image_id, ListingImage.listing_id == listing_id).first()
    if img:
        img.is_primary = True
        db.commit()
        return True
    db.commit()
    return False
