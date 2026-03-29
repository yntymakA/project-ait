from decimal import Decimal
from sqlalchemy.orm import Session
from fastapi import HTTPException
from typing import Optional
from app.models.sql_models.user import User
from app.models.enums import TransactionTypeEnum, PromotionTypeEnum, NotificationTypeEnum
from app.repositories import payment_repo, promotion_repo, listing_repo
from app.services.notification import notification_service


def get_available_packages(db: Session):
    items = promotion_repo.get_active_packages(db)
    return {"items": items}


def purchase_promotion(
    db: Session,
    current_user: User,
    listing_id: Optional[int],
    package_id: int,
    target_city: Optional[str] = None,
    target_category_id: Optional[int] = None,
):
    listing = None

    # 1. Validate package
    package = promotion_repo.get_package_by_id(db, package_id)
    if not package:
        raise HTTPException(status_code=404, detail="Promotion package not found or inactive")

    if package.promotion_type != PromotionTypeEnum.featured:
        raise HTTPException(
            status_code=400,
            detail="Only featured promotions are available right now",
        )

    # 2. If listing is provided, enforce ownership (optional for profile badge purchase)
    if listing_id is not None:
        listing = listing_repo.get_listing(db, listing_id)
        if not listing:
            raise HTTPException(status_code=404, detail="Listing not found")
        if listing.owner_id != current_user.id:
            raise HTTPException(
                status_code=403,
                detail="You can only promote your own listings",
            )

    # 3. Check balance
    if Decimal(str(current_user.balance)) < package.price:
        raise HTTPException(
            status_code=400,
            detail=f"Insufficient balance. Required: {package.price}, available: {current_user.balance}",
        )

    # 4. Deduct balance (atomic lock)
    payment_repo.add_to_balance(db, current_user.id, -package.price)

    # 5. Record spend transaction (shown in wallet / transaction history)
    if listing is not None:
        spend_desc = f"Featured badge: {package.name} (listing #{listing.id})"
    else:
        spend_desc = f"Featured badge: {package.name} (profile)"
    payment_repo.create_transaction(
        db=db,
        user_id=current_user.id,
        type=TransactionTypeEnum.spend,
        amount=package.price,
        description=spend_desc,
    )

    # 6. Create promotion record
    promo = promotion_repo.create_promotion(
        db=db,
        listing_id=listing.id if listing is not None else None,
        user_id=current_user.id,
        package=package,
        target_city=target_city,
        target_category_id=target_category_id,
    )

    db.commit()
    db.refresh(promo)

    # 🔔 Notify user about promotion activation
    notification_service.send_notification(
        db, current_user.id,
        NotificationTypeEnum.promotion_activated,
        {
            "listing_id": listing.id if listing is not None else None,
            "package": package.name,
            "message": "Featured badge activated",
        }
    )

    return promo


def expire_promotions(db: Session) -> int:
    """Cron-callable helper: sweeps all expired promotions and marks them expired."""
    return promotion_repo.expire_old_promotions(db)
