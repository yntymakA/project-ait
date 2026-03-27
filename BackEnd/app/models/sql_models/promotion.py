from sqlalchemy import Column, BigInteger, Integer, String, Numeric, Enum, DateTime, ForeignKey
from sqlalchemy.sql import func
from app.db.base import Base
from app.models.enums import PromotionTypeEnum, PromotionStatusEnum

class Promotion(Base):
    __tablename__ = "promotions"

    id = Column(BigInteger, primary_key=True, autoincrement=True, index=True)
    listing_id = Column(BigInteger, ForeignKey("listings.id"), nullable=False, index=True)
    user_id = Column(BigInteger, ForeignKey("users.id"), nullable=False, index=True)
    package_id = Column(Integer, ForeignKey("promotion_packages.id"), nullable=True)
    
    promotion_type = Column(Enum(PromotionTypeEnum), nullable=False)
    target_city = Column(String(100), nullable=True)
    target_category_id = Column(Integer, ForeignKey("categories.id"), nullable=True)
    
    status = Column(Enum(PromotionStatusEnum), default=PromotionStatusEnum.pending, nullable=False)
    purchased_price = Column(Numeric(12, 2), nullable=False)
    
    starts_at = Column(DateTime, nullable=True)
    ends_at = Column(DateTime, nullable=True)
    created_at = Column(DateTime, server_default=func.now(), nullable=False)
