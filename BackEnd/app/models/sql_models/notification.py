from sqlalchemy import Column, BigInteger, Enum, Boolean, JSON, DateTime, ForeignKey
from sqlalchemy.sql import func
from app.db.base import Base
from app.models.enums import NotificationTypeEnum

class Notification(Base):
    __tablename__ = "notifications"

    id = Column(BigInteger, primary_key=True, autoincrement=True, index=True)
    user_id = Column(BigInteger, ForeignKey("users.id"), nullable=False, index=True)
    type = Column(Enum(NotificationTypeEnum), nullable=False)
    is_read = Column(Boolean, default=False, nullable=False)
    payload = Column(JSON, nullable=True)#json form
    created_at = Column(DateTime, server_default=func.now(), nullable=False)
