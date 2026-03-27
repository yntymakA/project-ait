from pydantic import BaseModel, ConfigDict
from decimal import Decimal
from datetime import datetime
from typing import Optional
from app.models.enums import TransactionTypeEnum


class TopUpRequest(BaseModel):
    amount: Decimal
    payment_method: str = "credit_card"


class TransactionResponse(BaseModel):
    id: int
    user_id: int
    type: TransactionTypeEnum
    amount: Decimal
    description: Optional[str] = None
    created_at: datetime

    model_config = ConfigDict(from_attributes=True)


class TransactionListResponse(BaseModel):
    items: list[TransactionResponse]
    total: int
    limit: int
    offset: int
