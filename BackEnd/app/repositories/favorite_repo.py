from sqlalchemy.orm import Session
from app.models.sql_models.favorite import Favorite
from app.models.sql_models.listing import Listing

def get_favorite(db: Session, user_id: int, listing_id: int) -> Favorite | None:
    return db.query(Favorite).filter(
        Favorite.user_id == user_id,
        Favorite.listing_id == listing_id
    ).first()

def add_favorite(db: Session, user_id: int, listing_id: int) -> Favorite:
    fav = Favorite(user_id=user_id, listing_id=listing_id)
    db.add(fav)
    db.commit()
    db.refresh(fav)
    return fav

def remove_favorite(db: Session, user_id: int, listing_id: int) -> bool:
    fav = get_favorite(db, user_id, listing_id)
    if fav:
        db.delete(fav)
        db.commit()
        return True
    return False

def get_user_favorites(db: Session, user_id: int, skip: int = 0, limit: int = 20) -> tuple[int, list[Listing]]:
    total = db.query(Favorite).filter(Favorite.user_id == user_id).count()
    listings = (
        db.query(Listing)
        .join(Favorite, Favorite.listing_id == Listing.id)
        .filter(Favorite.user_id == user_id)
        .order_by(Favorite.created_at.desc())
        .offset(skip)
        .limit(limit)
        .all()
    )
    return total, listings
