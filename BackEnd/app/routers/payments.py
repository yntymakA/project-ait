from fastapi import APIRouter, Depends, Query, status
from sqlalchemy.orm import Session
from decimal import Decimal
from app.core.dependencies import get_db, get_current_user
from app.models.sql_models.user import User
from app.schemas.payment import TopUpRequest, TransactionResponse, TransactionListResponse
from app.services.payment import payment_service

router = APIRouter(prefix="/payments", tags=["Monetization – Payments"])


@router.post(
    "/top-up",
    response_model=TransactionResponse,
    status_code=status.HTTP_201_CREATED,
    summary="Top up your account balance",
)
def top_up(
    data: TopUpRequest,
    db: Session = Depends(get_db),
    user: User = Depends(get_current_user),
):
    """Simulates a payment gateway callback that credits the user's internal wallet."""
    return payment_service.top_up_balance(db, user, data.amount, data.payment_method)


@router.get(
    "/history",
    response_model=TransactionListResponse,
    summary="View your transaction history",
)
def transaction_history(
    limit: int = Query(20, ge=1, le=100),
    offset: int = Query(0, ge=0),
    db: Session = Depends(get_db),
    user: User = Depends(get_current_user),
):
    """Returns a paginated list of all top-ups and spends for the current user."""
    return payment_service.get_transaction_history(db, user, limit, offset)
