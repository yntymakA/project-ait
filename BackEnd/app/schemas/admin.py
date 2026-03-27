from pydantic import BaseModel
from typing import Optional
from app.models.enums import UserStatusEnum, ModerationStatusEnum, ReportStatusEnum

class AdminDashboardStats(BaseModel):
    total_users: int
    active_users: int
    total_listings: int
    pending_listings: int
    open_reports: int

class UserModerationRequest(BaseModel):
    status: UserStatusEnum
    
class ListingModerationRequest(BaseModel):
    status: ModerationStatusEnum

class ReportResolutionRequest(BaseModel):
    status: ReportStatusEnum
    resolution_note: Optional[str] = None
