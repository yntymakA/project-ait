from sqlalchemy.orm import Session
from app.models.sql_models.listing import Listing

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
