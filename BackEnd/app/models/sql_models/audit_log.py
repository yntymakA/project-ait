from sqlalchemy import Column, BigInteger, String, Text, DateTime, ForeignKey
from sqlalchemy.sql import func
from app.db.base import Base

class AdminAuditLog(Base):
    __tablename__ = "admin_audit_logs"

    id = Column(BigInteger, primary_key=True, autoincrement=True, index=True)
    admin_id = Column(BigInteger, ForeignKey("users.id"), nullable=False, index=True)
    action = Column(String(100), nullable=False)#ban_user
    target_type = Column(String(50), nullable=False)#Тип объекта: "user", "listing", "category", "review"
    target_id = Column(BigInteger, nullable=False, index=True)
    note = Column(Text, nullable=True)#«Опишите причину бана (для истории)». 
    created_at = Column(DateTime, server_default=func.now(), nullable=False)
