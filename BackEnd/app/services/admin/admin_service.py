from sqlalchemy.orm import Session
from fastapi import HTTPException
from app.repositories import user_repo, listing_repo, report_repo
from app.models.enums import UserStatusEnum, ModerationStatusEnum, ReportStatusEnum
from app.schemas.admin import UserModerationRequest, ListingModerationRequest, ReportResolutionRequest

def get_dashboard_stats(db: Session):
    return {
        "total_users": user_repo.count_users(db, status=None),
        "active_users": user_repo.count_users(db, status=UserStatusEnum.active),
        "total_listings": listing_repo.count_listings(db, moderation_status=None),
        "pending_listings": listing_repo.count_listings(db, moderation_status=ModerationStatusEnum.pending),
        "open_reports": report_repo.count_reports(db, status=ReportStatusEnum.open)
    }

def moderate_user(db: Session, user_id: int, request: UserModerationRequest):
    user = user_repo.get_user(db, user_id)
    if not user:
        raise HTTPException(status_code=404, detail="User not found")
        
    user.status = request.status
    db.commit()
    db.refresh(user)
    return user

def moderate_listing(db: Session, listing_id: int, request: ListingModerationRequest):
    listing = listing_repo.get_listing(db, listing_id)
    if not listing:
        raise HTTPException(status_code=404, detail="Listing not found")
        
    listing.moderation_status = request.status
    db.commit()
    db.refresh(listing)
    return listing

def resolve_report(db: Session, report_id: int, request: ReportResolutionRequest, admin_id: int):
    report = report_repo.update_report_status(db, report_id, request.status, admin_id, request.resolution_note)
    if not report:
        raise HTTPException(status_code=404, detail="Report not found")
    return report

def get_listings_queue(db: Session, limit: int, offset: int):
    return listing_repo.get_paginated_listings(db, skip=offset, limit=limit)
