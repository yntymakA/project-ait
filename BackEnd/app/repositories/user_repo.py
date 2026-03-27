from sqlalchemy.orm import Session
from sqlalchemy import func
from app.models.sql_models.user import User
from app.schemas.user import UserBase, UserUpdate
from app.models.enums import UserStatusEnum

def get_user(db: Session, user_id: int) -> User | None:
    return db.query(User).filter(User.id == user_id).first()

def count_users(db: Session, status: UserStatusEnum = None) -> int:
    query = db.query(func.count(User.id))
    if status:
        query = query.filter(User.status == status)
    return query.scalar() or 0

def get_user_by_firebase_uid(db: Session, firebase_uid: str) -> User | None:
    return db.query(User).filter(User.firebase_uid == firebase_uid).first()

def get_user_by_email(db: Session, email: str) -> User | None:
    return db.query(User).filter(User.email == email).first()

def create_user(db: Session, firebase_uid: str, email: str, full_name: str, profile_image_url: str = None) -> User:
    db_user = User(
        firebase_uid=firebase_uid,
        email=email,
        full_name=full_name,
        profile_image_url=profile_image_url
    )
    db.add(db_user)
    db.commit()
    db.refresh(db_user)
    return db_user

def update_user(db: Session, db_user: User, update_data: UserUpdate) -> User:
    update_dict = update_data.model_dump(exclude_unset=True)
    for key, value in update_dict.items():
        setattr(db_user, key, value)
    
    db.commit()
    db.refresh(db_user)
    return db_user


def count_active_listings(db: Session, user_id: int) -> int:
    from app.models.sql_models.listing import Listing
    from app.models.enums import ModerationStatusEnum
    return (
        db.query(func.count(Listing.id))
        .filter(
            Listing.owner_id == user_id,
            Listing.moderation_status == ModerationStatusEnum.approved,
            Listing.deleted_at == None,
        )
        .scalar() or 0
    )


def get_user_listings(db: Session, user_id: int, skip: int = 0, limit: int = 20):
    from app.models.sql_models.listing import Listing
    from app.models.enums import ModerationStatusEnum
    query = db.query(Listing).filter(
        Listing.owner_id == user_id,
        Listing.moderation_status == ModerationStatusEnum.approved,
        Listing.deleted_at == None,
    )
    total = query.count()
    items = query.order_by(Listing.created_at.desc()).offset(skip).limit(limit).all()
    return total, items
