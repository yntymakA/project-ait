from sqlalchemy.orm import Session, joinedload
from sqlalchemy import func, case
from fastapi import HTTPException
from app.models.sql_models.listing import Listing, ListingImage
from app.models.sql_models.promotion import Promotion
from app.models.enums import ModerationStatusEnum, PromotionStatusEnum, PromotionTypeEnum

MAX_LISTING_IMAGES = 3

def create_listing(db: Session, owner_id: int, **kwargs) -> Listing:
    listing = Listing(owner_id=owner_id, **kwargs)
    db.add(listing)
    db.commit()
    db.refresh(listing)
    return listing

def get_listing(db: Session, listing_id: int) -> Listing | None:
    return (
        db.query(Listing)
        .filter(Listing.id == listing_id, Listing.deleted_at == None)
        .first()
    )

def update_listing(db: Session, listing: Listing, update_data: dict) -> Listing:
    for key, value in update_data.items():
        setattr(listing, key, value)
    db.commit()
    db.refresh(listing)
    return listing

def get_listings_by_owner(db: Session, owner_id: int, skip: int = 0, limit: int = 20) -> list[Listing]:
    return db.query(Listing).filter(Listing.owner_id == owner_id, Listing.deleted_at == None).offset(skip).limit(limit).all()

def count_listings(db: Session, moderation_status: ModerationStatusEnum = None) -> int:
    query = db.query(func.count(Listing.id)).filter(Listing.deleted_at == None)
    if moderation_status:
        query = query.filter(Listing.moderation_status == moderation_status)
    return query.scalar() or 0

def get_paginated_listings(
    db: Session,
    page: int = 1,
    page_size: int = 50,
    q: str | None = None,
    category_id: int | None = None,
    city: str | None = None,
    min_price: float | None = None,
    max_price: float | None = None,
    status: ModerationStatusEnum | None = None,
    sort: str = "newest",
) -> tuple[int, list[Listing]]:
    """
    Public listing feed with filters, search, and sorting.
    top_feed-promoted listings always appear first regardless of sort.
    Returns (total_count, items) for paginated response.
    """
    # Subquery: does this listing have an active top_feed promotion?
    has_top_feed = (
        db.query(Promotion.listing_id)
        .filter(
            Promotion.status == PromotionStatusEnum.active,
            Promotion.promotion_type == PromotionTypeEnum.top_feed,
        )
        .subquery()
    )

    is_promoted = Listing.id.in_(has_top_feed)

    query = (
        db.query(Listing)
        .filter(Listing.deleted_at == None)
    )

    # ── Filters ───────────────────────────────────────────
    if q:
        pattern = f"%{q}%"
        query = query.filter((Listing.title.ilike(pattern)) | (Listing.description.ilike(pattern)))
    if category_id is not None:
        query = query.filter(Listing.category_id == category_id)
    if city:
        query = query.filter(Listing.city.ilike(f"%{city}%"))
    if min_price is not None:
        query = query.filter(Listing.price >= min_price)
    if max_price is not None:
        query = query.filter(Listing.price <= max_price)
    if status is not None:
        query = query.filter(Listing.moderation_status == status)

    # ── Total count (before pagination) ────────────────────
    total = query.count()

    # ── Sorting (promoted always first) ────────────────────
    sort_options = {
        "newest": Listing.created_at.desc(),
        "oldest": Listing.created_at.asc(),
        "price_asc": Listing.price.asc(),
        "price_desc": Listing.price.desc(),
    }
    secondary_sort = sort_options.get(sort, Listing.created_at.desc())

    # ── Pagination ─────────────────────────────────────────
    skip = (page - 1) * page_size
    items = (
        query.order_by(
            case((is_promoted, 1), else_=0).desc(),  # promoted first
            secondary_sort,
        )
        .offset(skip)
        .limit(page_size)
        .all()
    )

    return total, items

def count_listing_images(db: Session, listing_id: int) -> int:
    return db.query(func.count(ListingImage.id)).filter(ListingImage.listing_id == listing_id).scalar() or 0

def add_listing_image(db: Session, listing_id: int, file_url: str, is_primary: bool = False) -> ListingImage:
    current_count = count_listing_images(db, listing_id)
    if current_count >= MAX_LISTING_IMAGES:
        raise HTTPException(
            status_code=400,
            detail=f"A listing can have at most {MAX_LISTING_IMAGES} images."
        )

    next_order = current_count + 1

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
