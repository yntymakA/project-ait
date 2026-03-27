from pydantic import BaseModel, ConfigDict
from datetime import datetime
from typing import Optional, List
from builtins import int

class ConversationCreate(BaseModel):
    listing_id: int
    recipient_id: int

class ConversationResponse(BaseModel):
    id: int
    listing_id: int
    participant_a_id: int
    participant_b_id: int
    last_message_at: Optional[datetime] = None
    created_at: datetime
    
    model_config = ConfigDict(from_attributes=True)

class ConversationListInfo(BaseModel):
    id: int
    listing_id: int
    listing_title: str
    other_participant_id: int
    other_participant_name: str
    last_message_text: Optional[str] = None
    last_message_at: Optional[datetime] = None
    unread_count: int = 0
    
class ConversationListResponse(BaseModel):
    items: List[ConversationListInfo]
    total: int
    limit: int
    offset: int
