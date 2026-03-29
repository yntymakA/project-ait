from fastapi import APIRouter, Depends, Query, status
from sqlalchemy.orm import Session
from app.core.dependencies import get_db, get_current_user
from app.models.sql_models.user import User
from app.schemas.conversation import ConversationCreate, ConversationResponse, ConversationListResponse
from app.schemas.message import MessageResponse, MessageListResponse, MessageCreate
from app.services.conversation import conversation_service

router = APIRouter(prefix="/conversations", tags=["Conversations"])

@router.post("", response_model=ConversationResponse, status_code=status.HTTP_201_CREATED)
def start_conversation(
    data: ConversationCreate,
    db: Session = Depends(get_db),
    user: User = Depends(get_current_user)
):
    """Start or reopen a conversation about a specific listing."""
    return conversation_service.start_conversation(db, user, data.listing_id, data.recipient_id)

@router.get("", response_model=ConversationListResponse)
def get_user_conversations(
    limit: int = Query(20, ge=1, le=100),
    offset: int = Query(0, ge=0),
    db: Session = Depends(get_db),
    user: User = Depends(get_current_user)
):
    """List all conversations for the current user."""
    return conversation_service.get_user_conversations(db, user, limit, offset)

@router.get("/{conversation_id}/messages", response_model=MessageListResponse)
def get_messages(
    conversation_id: int,
    limit: int = Query(50, ge=1, le=100),
    offset: int = Query(0, ge=0),
    db: Session = Depends(get_db),
    user: User = Depends(get_current_user)
):
    """Get message history for a conversation."""
    return conversation_service.get_conversation_messages(db, user, conversation_id, limit, offset)

@router.post("/{conversation_id}/messages", response_model=MessageResponse, status_code=status.HTTP_201_CREATED)
def send_message(
    conversation_id: int,
    body: MessageCreate,
    db: Session = Depends(get_db),
    user: User = Depends(get_current_user)
):
    """Send a text-only message in a conversation."""
    return conversation_service.send_message(db, user, conversation_id, body.text_body)
