from pydantic import BaseModel, ConfigDict
from datetime import datetime
from typing import Optional, List
from builtins import int
from app.models.enums import MessageTypeEnum

class MessageAttachmentResponse(BaseModel):
    id: int
    original_name: str
    mime_type: Optional[str] = None
    file_size: Optional[int] = None
    file_url: str
    
    model_config = ConfigDict(from_attributes=True)

class MessageResponse(BaseModel):
    id: int
    conversation_id: int
    sender_id: int
    message_type: MessageTypeEnum
    text_body: Optional[str] = None
    is_read: bool
    sent_at: datetime
    attachments: List[MessageAttachmentResponse] = []
    
    model_config = ConfigDict(from_attributes=True)

class MessageListResponse(BaseModel):
    items: List[MessageResponse]
    total: int
    limit: int
    offset: int
