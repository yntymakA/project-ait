from collections.abc import Generator
from sqlalchemy.orm import Session
from app.db.session import SessionLocal

def get_db() -> Generator[Session, None, None]:
    """
    FastAPI dependency that provides a SQLAlchemy session for a request and closes it when done.
    """
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()

from typing import Annotated
from fastapi import Depends, HTTPException, status
from app.core.security import get_current_firebase_uid
from app.repositories import user_repo

def get_current_user(
    firebase_payload: Annotated[dict, Depends(get_current_firebase_uid)],
    db: Session = Depends(get_db)
):
    """Dependency that returns the actual User DB model.
        takes actual user from our db using u_id
    """
    uid = firebase_payload.get("uid")
    user = user_repo.get_user_by_firebase_uid(db, uid)
    if not user:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED, 
            detail="User not found in database. Please call /sync first."
        )
    return user
