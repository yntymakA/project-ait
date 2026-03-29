from fastapi import APIRouter, Depends, HTTPException, UploadFile, File, Query, status
from sqlalchemy.orm import Session
from typing import Annotated

from app.core.dependencies import get_db, get_current_user
from app.core.security import get_current_firebase_uid
from app.schemas.user import (
    UserResponse,
    UserSyncResponse,
    UserUpdate,
    PublicUserResponse,
    UserPublicListingsResponse,
)
from app.services.user import user_service
from app.services.storage import upload_service
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


@router.post("/me/avatar", summary="Upload profile image")
def upload_avatar(
    file: UploadFile = File(..., description="Profile image (jpg, png, webp)"),
    current_user = Depends(get_current_user),
    db: Session = Depends(get_db),
):
    """Upload or replace the current user's profile avatar."""
    # Validate file type
    allowed = {"image/jpeg", "image/png", "image/webp"}
    if file.content_type not in allowed:
        raise HTTPException(status_code=415, detail=f"File type not allowed: {file.content_type}")

    url = upload_service.upload_image_to_firebase(file, folder="avatars")
    current_user.profile_image_url = url
    db.commit()
    db.refresh(current_user)
    return {"profile_image_url": url}


# ── Public endpoints (no auth required) ──────────────────

@router.get("/public/{user_id}", response_model=PublicUserResponse, summary="Public user profile")
def get_public_profile(user_id: int, db: Session = Depends(get_db)):
    """Public profile page — visible to anyone, no auth required."""
    user = user_repo.get_user(db, user_id)
    if not user:
        raise HTTPException(status_code=404, detail="User not found")
    
    active_count = user_repo.count_active_listings(db, user_id)
    return {
        "id": user.id,
        "full_name": user.full_name,
        "profile_image_url": user.profile_image_url,
        "city": user.city,
        "member_since": user.created_at,
        "active_listing_count": active_count,
    }


@router.get(
    "/public/{user_id}/listings",
    response_model=UserPublicListingsResponse,
    summary="Seller's listings",
)
def get_user_listings(
    user_id: int,
    limit: int = Query(20, ge=1, le=100),
    offset: int = Query(0, ge=0),
    db: Session = Depends(get_db),
):
    """All approved public listings by a specific owner. Paginated."""
    user = user_repo.get_user(db, user_id)
    if not user:
        raise HTTPException(status_code=404, detail="User not found")

    total, items = user_repo.get_user_listings(db, user_id, skip=offset, limit=limit)
    return {"items": items, "total": total, "limit": limit, "offset": offset}
