from sqlalchemy import Column, BigInteger, Integer, String, Text, Numeric, Enum, Boolean, DateTime, ForeignKey
from sqlalchemy.sql import func
from sqlalchemy.orm import relationship
from app.db.base import Base
from app.models.enums import ListingStatusEnum, ModerationStatusEnum, PromotionStatusEnum

class Listing(Base):
    __tablename__ = "listings"

    id = Column(BigInteger, primary_key=True, autoincrement=True, index=True)
    owner_id = Column(BigInteger, ForeignKey("users.id"), nullable=False, index=True)
    category_id = Column(Integer, ForeignKey("categories.id"), nullable=False)
    title = Column(String(255), nullable=False)
    description = Column(Text, nullable=False)
    price = Column(Numeric(12, 2), nullable=False)
    currency = Column(String(10), default="USD", nullable=False)
    city = Column(String(100), nullable=True)
    
    status = Column(Enum(ListingStatusEnum), default=ListingStatusEnum.draft, nullable=False)
    moderation_status = Column(Enum(ModerationStatusEnum), default=ModerationStatusEnum.approved, nullable=False)  # default approved until admin panel
    promotion_status = Column(Enum(PromotionStatusEnum), default=PromotionStatusEnum.none, nullable=False)
    
    view_count = Column(Integer, default=0, nullable=False)
    is_negotiable = Column(Boolean, default=False, nullable=False)

    deleted_at = Column(DateTime, nullable=True)
    published_at = Column(DateTime, nullable=True)
    expires_at = Column(DateTime, nullable=True)
    created_at = Column(DateTime, server_default=func.now(), nullable=False)
    updated_at = Column(DateTime, server_default=func.now(), onupdate=func.now(), nullable=False)
    
    # Relationships
    images = relationship("ListingImage", backref="listing", cascade="all, delete-orphan")

class ListingImage(Base):
    __tablename__ = "listing_images"

    id = Column(BigInteger, primary_key=True, autoincrement=True, index=True)
    listing_id = Column(BigInteger, ForeignKey("listings.id"), nullable=False, index=True)
    file_url = Column(Text, nullable=False)
    is_primary = Column(Boolean, default=False, nullable=False)
    order_index = Column(Integer, default=0, nullable=False)
    created_at = Column(DateTime, server_default=func.now(), nullable=False)
