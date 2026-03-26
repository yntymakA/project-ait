from sqlalchemy import Column, BigInteger, String, Text, Numeric, Enum, DateTime
from sqlalchemy.sql import func
from app.db.base import Base
from app.models.enums import RoleEnum, UserStatusEnum

class User(Base):
    __tablename__ = "users"

    id = Column(BigInteger, primary_key=True, autoincrement=True, index=True)
    firebase_uid = Column(String(128), unique=True, index=True, nullable=True) # nullable for cases before auth sync
    full_name = Column(String(255), nullable=False)
    email = Column(String(255), unique=True, nullable=False, index=True)
    phone = Column(String(30), unique=True, nullable=True)
    balance = Column(Numeric(12, 2), default=0.00, nullable=False)
    role = Column(Enum(RoleEnum), default=RoleEnum.user, nullable=False)
    status = Column(Enum(UserStatusEnum), default=UserStatusEnum.active, nullable=False)
    profile_image_url = Column(Text, nullable=True)
    bio = Column(Text, nullable=True)
    city = Column(String(100), nullable=True)
    preferred_language = Column(String(10), default="ru", nullable=True)
    
    last_seen_at = Column(DateTime, nullable=True)
    created_at = Column(DateTime, server_default=func.now(), nullable=False)
    updated_at = Column(DateTime, server_default=func.now(), onupdate=func.now(), nullable=False)
