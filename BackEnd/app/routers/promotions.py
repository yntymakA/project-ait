from fastapi import APIRouter, Depends, status
from sqlalchemy.orm import Session
from app.core.dependencies import get_db, get_current_user
from app.models.sql_models.user import User
from app.schemas.promotion import (
    PromotionPackageListResponse,
    PurchasePromotionRequest,
    PromotionResponse,
)
from app.services.promotion import promotion_service

router = APIRouter(prefix="/promotions", tags=["Monetization – Promotions"])


@router.get(
    "/packages",
    response_model=PromotionPackageListResponse,
    summary="List available promotion packages",
)
def list_packages(db: Session = Depends(get_db)):
    """Returns all active promotion tiers that users can purchase."""
    return promotion_service.get_available_packages(db)


@router.post(
    "/purchase",
    response_model=PromotionResponse,
    status_code=status.HTTP_201_CREATED,
    summary="Purchase featured badge promotion",
)
def purchase_promotion(
    data: PurchasePromotionRequest,
    db: Session = Depends(get_db),
    user: User = Depends(get_current_user),
):
    """
    Deducts package price from user balance and activates Featured immediately.
    Optionally pass `listing_id` to associate this Featured badge with a specific listing.
    """
    return promotion_service.purchase_promotion(
        db=db,
        current_user=user,
        listing_id=data.listing_id,
        package_id=data.package_id,
        target_city=data.target_city,
        target_category_id=data.target_category_id,
    )
