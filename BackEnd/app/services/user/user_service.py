from sqlalchemy.orm import Session
from app.repositories import user_repo
from app.models.sql_models.user import User
from app.schemas.user import UserUpdate

def sync_firebase_user(db: Session, firebase_payload: dict) -> User:
    """
    Called after successful Firebase token validation. 
    Finds existing user by checking python dict mapped from jwt, 
    or creates a new user if not found.
    """
    uid = firebase_payload.get("uid")
    email = firebase_payload.get("email")
    name = firebase_payload.get("name", "Firebase User")
    picture = firebase_payload.get("picture")

    if not uid or not email:
        raise ValueError("Firebase token is missing required uid or email fields")

    # 1. Try to find by UID
    user = user_repo.get_user_by_firebase_uid(db, uid)
    if user:
        return user

    # 2. Try to find by email (if they logged in with a different provider but same email)
    user = user_repo.get_user_by_email(db, email)
    if user:
        # Link the account
        user.firebase_uid = uid
        db.commit()
        db.refresh(user)
        return user
    
    # 3. Create new user
    return user_repo.create_user(
        db=db,
        firebase_uid=uid,
        email=email,
        full_name=name,
        profile_image_url=picture
    )

def update_user_profile(db: Session, user: User, update_data: UserUpdate) -> User:
    return user_repo.update_user(db, user, update_data)
