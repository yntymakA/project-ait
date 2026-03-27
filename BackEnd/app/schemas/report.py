from pydantic import BaseModel, ConfigDict
from builtins import int
from typing import Optional
from datetime import datetime
from app.models.enums import ReportTargetTypeEnum, ReportStatusEnum

class ReportCreate(BaseModel):
    target_type: ReportTargetTypeEnum
    target_id: int
    reason_code: str
    reason_text: Optional[str] = None

class ReportResponse(BaseModel):
    id: int
    reporter_user_id: int
    target_type: ReportTargetTypeEnum
    target_id: int
    reason_code: str
    reason_text: Optional[str] = None
    status: ReportStatusEnum
    reviewed_by_admin_id: Optional[int] = None
    resolution_note: Optional[str] = None
    created_at: datetime
    reviewed_at: Optional[datetime] = None
    
    model_config = ConfigDict(from_attributes=True)

class ReportListResponse(BaseModel):
    items: list[ReportResponse]
    total: int
    limit: int
    offset: int
