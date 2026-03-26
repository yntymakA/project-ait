from sqlalchemy import Column, BigInteger, String, Text, Enum, DateTime, ForeignKey
from sqlalchemy.sql import func
from app.db.base import Base
from app.models.enums import ReportTargetTypeEnum, ReportStatusEnum

class Report(Base):
    __tablename__ = "reports"

    id = Column(BigInteger, primary_key=True, autoincrement=True, index=True)
    reporter_user_id = Column(BigInteger, ForeignKey("users.id"), nullable=False, index=True)
    
    target_type = Column(Enum(ReportTargetTypeEnum), nullable=False)
    target_id = Column(BigInteger, nullable=False, index=True)
    
    reason_code = Column(String(50), nullable=False)
    reason_text = Column(Text, nullable=True)
    status = Column(Enum(ReportStatusEnum), default=ReportStatusEnum.open, nullable=False)
    
    reviewed_by_admin_id = Column(BigInteger, ForeignKey("users.id"), nullable=True)
    resolution_note = Column(Text, nullable=True)
    
    created_at = Column(DateTime, server_default=func.now(), nullable=False)
    reviewed_at = Column(DateTime, nullable=True)
