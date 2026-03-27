from decimal import Decimal
from datetime import datetime
from sqlalchemy.orm import Session
from fastapi import HTTPException
from typing import Optional
from app.models.sql_models.user import User
from app.models.enums import TransactionTypeEnum, PromotionTypeEnum
from app.repositories import payment_repo, promotion_repo, listing_repo


def get_available_packages(db: Session):
    items = promotion_repo.get_active_packages(db)
    return {"items": items}


def purchase_promotion(
    db: Session,
    current_user: User,
    listing_id: int,
    package_id: int,
    target_city: Optional[str] = None,
    target_category_id: Optional[int] = None,
):
    # 1. Validate listing exists and belongs to caller
    listing = listing_repo.get_listing(db, listing_id)
    if not listing:
        raise HTTPException(status_code=404, detail="Listing not found")
    if listing.owner_id != current_user.id:
        raise HTTPException(
            status_code=403,
            detail="You can only promote your own listings",
        )

    # 2. Validate package
    package = promotion_repo.get_package_by_id(db, package_id)
    if not package:
        raise HTTPException(status_code=404, detail="Promotion package not found or inactive")

    # 3. Check balance
    if Decimal(str(current_user.balance)) < package.price:
        raise HTTPException(
            status_code=400,
            detail=f"Insufficient balance. Required: {package.price}, available: {current_user.balance}",
        )

    # 4. Deduct balance (atomic lock)
    payment_repo.add_to_balance(db, current_user.id, -package.price)

    # 5. Record spend transaction
    payment_repo.create_transaction(
        db=db,
        user_id=current_user.id,
        type=TransactionTypeEnum.spend,
        amount=package.price,
        description=f"Promotion: '{package.name}' for Listing #{listing.id}",
    )

    # 6. Create promotion record
    promo = promotion_repo.create_promotion(
        db=db,
        listing_id=listing.id,
        user_id=current_user.id,
        package=package,
        target_city=target_city,
        target_category_id=target_category_id,
    )

    # 7. Special boost: bump created_at so listing floats to the top of chronological feeds
    if package.promotion_type == PromotionTypeEnum.boosted:
        listing.created_at = datetime.utcnow()

    db.commit()
    db.refresh(promo)
    return promo


def expire_promotions(db: Session) -> int:
    """Cron-callable helper: sweeps all expired promotions and marks them expired."""
    return promotion_repo.expire_old_promotions(db)
