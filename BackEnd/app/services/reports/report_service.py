from sqlalchemy.orm import Session
from fastapi import HTTPException
from app.schemas.report import ReportCreate
from app.repositories import report_repo, user_repo, listing_repo, message_repo
from app.models.sql_models.user import User
from app.models.enums import ReportTargetTypeEnum

def submit_report(db: Session, current_user: User, data: ReportCreate):
    # Validate the target exists
    if data.target_type == ReportTargetTypeEnum.user:
        if not user_repo.get_user(db, data.target_id):
            raise HTTPException(status_code=404, detail="Target user not found")
        if data.target_id == current_user.id:
            raise HTTPException(status_code=400, detail="Cannot report yourself")
            
    elif data.target_type == ReportTargetTypeEnum.listing:
        if not listing_repo.get_listing(db, data.target_id):
            raise HTTPException(status_code=404, detail="Target listing not found")
            
    elif data.target_type == ReportTargetTypeEnum.message:
        # Note: in real world, ensure user is participant in conversation of this message
        pass

    return report_repo.create_report(
        db=db,
        reporter_id=current_user.id,
        target_type=data.target_type,
        target_id=data.target_id,
        reason_code=data.reason_code,
        reason_text=data.reason_text
    )

def get_reports(db: Session, status, limit: int, offset: int):
    total, items = report_repo.get_reports(db, status=status, limit=limit, skip=offset)
    return {
        "items": items,
        "total": total,
        "limit": limit,
        "offset": offset
    }
