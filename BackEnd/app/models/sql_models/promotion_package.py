from sqlalchemy import Column, Integer, String, Numeric, Enum, Boolean
from app.db.base import Base
from app.models.enums import PromotionTypeEnum

class PromotionPackage(Base):
    __tablename__ = "promotion_packages"

    id = Column(Integer, primary_key=True, autoincrement=True, index=True)
    name = Column(String(100), nullable=False)
    promotion_type = Column(Enum(PromotionTypeEnum), nullable=False)
    duration_days = Column(Integer, nullable=False)
    price = Column(Numeric(12, 2), nullable=False)
    is_active = Column(Boolean, default=True, nullable=False)
