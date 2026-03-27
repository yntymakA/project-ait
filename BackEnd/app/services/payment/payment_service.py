from decimal import Decimal
from sqlalchemy.orm import Session
from fastapi import HTTPException
from app.models.sql_models.user import User
from app.models.enums import TransactionTypeEnum, NotificationTypeEnum
from app.repositories import payment_repo
from app.services.notification import notification_service


class TopUpRequest:
    """Inline here for simplicity; real schema is in app/schemas/payment.py"""
    pass


def top_up_balance(db: Session, current_user: User, amount: Decimal, payment_method: str = "credit_card"):
    if amount <= 0:
        raise HTTPException(status_code=400, detail="Amount must be greater than zero")

    # Debit user balance
    user = payment_repo.add_to_balance(db, current_user.id, amount)

    # Record transaction
    txn = payment_repo.create_transaction(
        db=db,
        user_id=current_user.id,
        type=TransactionTypeEnum.top_up,
        amount=amount,
        description=f"Top-up via {payment_method}",
    )
    db.commit()
    db.refresh(txn)

    # 🔔 Notify user about successful payment
    notification_service.send_notification(
        db, current_user.id,
        NotificationTypeEnum.payment_success,
        {"amount": str(amount), "message": f"Balance topped up by ${amount}"}
    )

    return txn



def get_transaction_history(db: Session, current_user: User, limit: int, offset: int):
    total, items = payment_repo.get_user_transactions(
        db, current_user.id, skip=offset, limit=limit
    )
    return {"items": items, "total": total, "limit": limit, "offset": offset}
