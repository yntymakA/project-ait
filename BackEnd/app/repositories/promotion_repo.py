from sqlalchemy.orm import Session
from datetime import datetime, timedelta
from typing import Optional
from app.models.sql_models.promotion import Promotion
from app.models.sql_models.promotion_package import PromotionPackage
from app.models.enums import PromotionStatusEnum


def get_active_packages(db: Session) -> list[PromotionPackage]:
    return (
        db.query(PromotionPackage)
        .filter(PromotionPackage.is_active == True)
        .order_by(PromotionPackage.price.asc())
        .all()
    )


def get_package_by_id(db: Session, package_id: int) -> PromotionPackage | None:
    return (
        db.query(PromotionPackage)
        .filter(PromotionPackage.id == package_id, PromotionPackage.is_active == True)
        .first()
    )


def create_promotion(
    db: Session,
    listing_id: int,
    user_id: int,
    package: PromotionPackage,
    target_city: Optional[str] = None,
    target_category_id: Optional[int] = None,
) -> Promotion:
    now = datetime.utcnow()
    promo = Promotion(
        listing_id=listing_id,
        user_id=user_id,
        package_id=package.id,
        promotion_type=package.promotion_type,
        target_city=target_city,
        target_category_id=target_category_id,
        status=PromotionStatusEnum.active,
        purchased_price=package.price,
        starts_at=now,
        ends_at=now + timedelta(days=package.duration_days),
    )
    db.add(promo)
    db.flush()
    return promo


def expire_old_promotions(db: Session) -> int:
    """Mark all active promotions whose ends_at is in the past as expired."""
    now = datetime.utcnow()
    count = (
        db.query(Promotion)
        .filter(
            Promotion.status == PromotionStatusEnum.active,
            Promotion.ends_at <= now,
        )
        .update({"status": PromotionStatusEnum.expired})
    )
    db.commit()
    return count
