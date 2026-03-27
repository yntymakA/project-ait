from sqlalchemy.orm import Session
from sqlalchemy import func
from app.models.sql_models.report import Report
from app.models.enums import ReportTargetTypeEnum, ReportStatusEnum
from typing import Optional
from datetime import datetime
from builtins import int

def create_report(db: Session, reporter_id: int, target_type: ReportTargetTypeEnum, target_id: int, reason_code: str, reason_text: Optional[str]) -> Report:
    report = Report(
        reporter_user_id=reporter_id,
        target_type=target_type,
        target_id=target_id,
        reason_code=reason_code,
        reason_text=reason_text,
        status=ReportStatusEnum.open
    )
    db.add(report)
    db.commit()
    db.refresh(report)
    return report

def get_report(db: Session, report_id: int) -> Report | None:
    return db.query(Report).filter(Report.id == report_id).first()

def count_reports(db: Session, status: Optional[ReportStatusEnum] = None) -> int:
    query = db.query(func.count(Report.id))
    if status:
        query = query.filter(Report.status == status)
    return query.scalar() or 0

def get_reports(db: Session, status: Optional[ReportStatusEnum] = None, skip: int = 0, limit: int = 20) -> tuple[int, list[Report]]:
    query = db.query(Report)
    if status:
        query = query.filter(Report.status == status)
        
    total = query.count()
    items = query.order_by(Report.created_at.desc()).offset(skip).limit(limit).all()
    return total, items

def update_report_status(db: Session, report_id: int, status: ReportStatusEnum, admin_id: int, resolution_note: Optional[str]) -> Report | None:
    report = get_report(db, report_id)
    if not report:
        return None
        
    report.status = status
    report.reviewed_by_admin_id = admin_id
    report.resolution_note = resolution_note
    report.reviewed_at = datetime.utcnow()
    
    db.commit()
    db.refresh(report)
    return report
