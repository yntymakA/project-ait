from fastapi import APIRouter, Depends, Query, status
from sqlalchemy.orm import Session
from app.core.dependencies import get_db, get_current_admin
from app.models.sql_models.user import User
from app.schemas.user import UserResponse
from app.schemas.listing import ListingResponse
from app.schemas.report import ReportListResponse, ReportResponse
from app.schemas.admin import AdminDashboardStats, UserModerationRequest, ListingModerationRequest, ReportResolutionRequest
from app.services.admin import admin_service
from app.services.reports import report_service
from app.models.enums import ReportStatusEnum
from typing import Optional

router = APIRouter(tags=["Admin"])

# We enforce get_current_admin at the router level in main.py, 
# but it's good practice to also inject it here if we need the admin user info.

@router.get("/stats", response_model=AdminDashboardStats)
def get_dashboard_stats(
    db: Session = Depends(get_db),
    admin: User = Depends(get_current_admin)
):
    """Retrieve aggregate statistics for the admin dashboard."""
    return admin_service.get_dashboard_stats(db)

@router.get("/reports", response_model=ReportListResponse)
def get_network_reports(
    status_filter: Optional[ReportStatusEnum] = Query(None, alias="status"),
    limit: int = Query(50, ge=1, le=100),
    offset: int = Query(0, ge=0),
    db: Session = Depends(get_db),
    admin: User = Depends(get_current_admin)
):
    """Get global paginated reports queue."""
    return report_service.get_reports(db, status_filter, limit, offset)

@router.patch("/reports/{report_id}/status", response_model=ReportResponse)
def resolve_report(
    report_id: int,
    data: ReportResolutionRequest,
    db: Session = Depends(get_db),
    admin: User = Depends(get_current_admin)
):
    """Mark a report as resolved or dismissed."""
    return admin_service.resolve_report(db, report_id, data, admin.id)

@router.patch("/users/{user_id}/status", response_model=UserResponse)
def moderate_user_status(
    user_id: int,
    data: UserModerationRequest,
    db: Session = Depends(get_db),
    admin: User = Depends(get_current_admin)
):
    """Suspend, ban, or activate a user account."""
    return admin_service.moderate_user(db, user_id, data)

@router.patch("/listings/{listing_id}/moderation", response_model=ListingResponse)
def moderate_listing_status(
    listing_id: int,
    data: ListingModerationRequest,
    db: Session = Depends(get_db),
    admin: User = Depends(get_current_admin)
):
    """Approve or reject a listing."""
    return admin_service.moderate_listing(db, listing_id, data)
