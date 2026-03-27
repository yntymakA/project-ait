from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session
from typing import Annotated

from app.core.dependencies import get_db, get_current_user
from app.core.security import get_current_firebase_uid
from app.schemas.user import UserResponse, UserSyncResponse, UserUpdate
from app.services.user import user_service
from app.repositories import user_repo

router = APIRouter(prefix="/users", tags=["Users"])

@router.post("/sync", response_model=UserSyncResponse, status_code=status.HTTP_200_OK)
def sync_user(
    firebase_payload: Annotated[dict, Depends(get_current_firebase_uid)],
    db: Session = Depends(get_db)
):
    """
    Syncs Firebase user with backend DB based on Bearer token.
    Call this immediately after client login/signup.
    """
    try:
        user = user_service.sync_firebase_user(db, firebase_payload)
        return user
    except ValueError as e:
        raise HTTPException(status_code=400, detail=str(e))

@router.get("/me", response_model=UserResponse)
def read_current_user(current_user = Depends(get_current_user)):
    """Get loaded profile for current authenticated user."""
    return current_user

@router.patch("/me", response_model=UserResponse)
def update_current_user(
    update_data: UserUpdate,
    current_user = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    """Update profile information for current user."""
    updated_user = user_service.update_user_profile(db, current_user, update_data)
    return updated_user
