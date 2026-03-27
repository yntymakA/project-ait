from fastapi import APIRouter, Depends, Query, status
from sqlalchemy.orm import Session
from app.core.dependencies import get_db, get_current_user
from app.models.sql_models.user import User
from app.schemas.report import ReportCreate, ReportResponse, ReportListResponse
from app.services.reports import report_service
from app.models.enums import ReportStatusEnum
from typing import Optional

router = APIRouter(prefix="/reports", tags=["Reports"])

@router.post("", response_model=ReportResponse, status_code=status.HTTP_201_CREATED)
def submit_report(
    data: ReportCreate,
    db: Session = Depends(get_db),
    user: User = Depends(get_current_user)
):
    """Submit a report against a user, listing, or message."""
    return report_service.submit_report(db, user, data)

@router.get("/my", response_model=ReportListResponse)
def get_my_reports(
    status_filter: Optional[ReportStatusEnum] = Query(None, alias="status"),
    limit: int = Query(20, ge=1, le=100),
    offset: int = Query(0, ge=0),
    db: Session = Depends(get_db),
    user: User = Depends(get_current_user)
):
    """(Optional) Get history of reports submitted by the current user."""
    # We can just leverage the repo function filtered by reporter_id
    from app.repositories import report_repo
    
    query = db.query(report_repo.Report).filter(report_repo.Report.reporter_user_id == user.id)
    if status_filter:
        query = query.filter(report_repo.Report.status == status_filter)
        
    total = query.count()
    items = query.order_by(report_repo.Report.created_at.desc()).offset(offset).limit(limit).all()
    
    return {
        "items": items,
        "total": total,
        "limit": limit,
        "offset": offset
    }
