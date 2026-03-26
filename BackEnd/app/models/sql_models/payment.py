from sqlalchemy import Column, BigInteger, String, Numeric, Enum, DateTime, ForeignKey
from sqlalchemy.sql import func
from app.db.base import Base
from app.models.enums import TransactionTypeEnum

class Transaction(Base):
    __tablename__ = "transactions"

    id = Column(BigInteger, primary_key=True, autoincrement=True, index=True)
    user_id = Column(BigInteger, ForeignKey("users.id"), nullable=False, index=True)
    type = Column(Enum(TransactionTypeEnum), nullable=False)
    amount = Column(Numeric(12, 2), nullable=False)
    description = Column(String(255), nullable=True)
    created_at = Column(DateTime, server_default=func.now(), nullable=False)
