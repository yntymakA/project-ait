from sqlalchemy.orm import Session
from fastapi import HTTPException
from app.repositories import user_repo, listing_repo, report_repo
from app.models.enums import (
    UserStatusEnum, ModerationStatusEnum, ReportStatusEnum, NotificationTypeEnum,
)
from app.schemas.admin import UserModerationRequest, ListingModerationRequest, ReportResolutionRequest
from app.schemas.search import ListingSearchParams
from app.schemas.pagination import create_paginated_response
from app.services.notification import notification_service
from app.services.search import search_service


def get_dashboard_stats(db: Session):
    return {
        "total_users": user_repo.count_users(db, status=None),
        "active_users": user_repo.count_users(db, status=UserStatusEnum.active),
        "total_listings": listing_repo.count_listings(db, moderation_status=None),
        "pending_listings": listing_repo.count_listings(db, moderation_status=ModerationStatusEnum.pending),
        "open_reports": report_repo.count_reports(db, status=ReportStatusEnum.open),
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

    # 🔔 Notify listing owner about moderation decision
    if request.status == ModerationStatusEnum.approved:
        notification_service.send_notification(
            db, listing.owner_id,
            NotificationTypeEnum.listing_approved,
            {"listing_id": listing.id, "title": listing.title, "message": f"Your listing '{listing.title}' has been approved!"}
        )
    elif request.status == ModerationStatusEnum.rejected:
        notification_service.send_notification(
            db, listing.owner_id,
            NotificationTypeEnum.listing_rejected,
            {"listing_id": listing.id, "title": listing.title, "message": f"Your listing '{listing.title}' was rejected"}
        )

    return listing


def resolve_report(db: Session, report_id: int, request: ReportResolutionRequest, admin_id: int):
    report = report_repo.update_report_status(db, report_id, request.status, admin_id, request.resolution_note)
    if not report:
        raise HTTPException(status_code=404, detail="Report not found")
    return report


def get_listings_queue(db: Session, page: int = 1, page_size: int = 50):
    """Admin moderation queue — returns only pending listings with standard pagination."""
    params = ListingSearchParams()
    params.page = page
    params.page_size = page_size
    params.status = ModerationStatusEnum.pending

    total, items = search_service.search_listings(db, params)
    return create_paginated_response(items, total, page, page_size)
def get_all_users(db: Session, page: int = 1, page_size: int = 50):
    """Admin users list — returns all users with standard pagination."""
    skip = (page - 1) * page_size
    total, items = user_repo.get_users_list(db, skip=skip, limit=page_size)
    return create_paginated_response(items, total, page, page_size)
