from sqlalchemy.orm import Session
from decimal import Decimal
from app.models.sql_models.payment import Transaction
from app.models.sql_models.user import User
from app.models.enums import TransactionTypeEnum


def create_transaction(
    db: Session,
    user_id: int,
    type: TransactionTypeEnum,
    amount: Decimal,
    description: str = None
) -> Transaction:
    txn = Transaction(
        user_id=user_id,
        type=type,
        amount=amount,
        description=description
    )
    db.add(txn)
    db.flush()  # get the ID without committing so callers can group with other writes
    return txn


def get_user_transactions(
    db: Session, user_id: int, skip: int = 0, limit: int = 20
) -> tuple[int, list[Transaction]]:
    query = db.query(Transaction).filter(Transaction.user_id == user_id)
    total = query.count()
    items = (
        query.order_by(Transaction.created_at.desc())
        .offset(skip)
        .limit(limit)
        .all()
    )
    return total, items


def add_to_balance(db: Session, user_id: int, delta: Decimal) -> User:
    """Atomically update user balance with a row-level lock (FOR UPDATE)."""
    user = (
        db.query(User)
        .filter(User.id == user_id)
        .with_for_update()
        .first()
    )
    if user:
        # Convert both to Decimal to ensure type safety
        current = Decimal(str(user.balance)) if user.balance is not None else Decimal("0")
        user.balance = current + Decimal(str(delta))
    return user

