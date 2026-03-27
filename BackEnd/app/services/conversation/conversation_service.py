from fastapi import HTTPException
from sqlalchemy.orm import Session
from app.repositories import conversation_repo, message_repo, listing_repo, user_repo
from app.models.sql_models.user import User
from app.models.enums import MessageTypeEnum
from app.services.storage import upload_service
from datetime import datetime

def start_conversation(db: Session, current_user: User, listing_id: int, recipient_id: int):
    if current_user.id == recipient_id:
        raise HTTPException(status_code=400, detail="Cannot start a conversation with yourself")
        
    listing = listing_repo.get_listing(db, listing_id)
    if not listing:
        raise HTTPException(status_code=404, detail="Listing not found")
        
    recipient = user_repo.get_user(db, recipient_id)
    if not recipient:
        raise HTTPException(status_code=404, detail="Recipient user not found")

    # Check auto-deduplication
    existing_conv = conversation_repo.get_conversation_by_participants(db, listing_id, current_user.id, recipient_id)
    if existing_conv:
        return existing_conv
        
    return conversation_repo.create_conversation(db, listing_id, current_user.id, recipient_id)

def get_user_conversations(db: Session, current_user: User, limit: int, offset: int):
    total, convs = conversation_repo.get_user_conversations(db, current_user.id, offset, limit)
    
    items = []
    for c in convs:
        listing = listing_repo.get_listing(db, c.listing_id)
        other_user_id = c.participant_b_id if c.participant_a_id == current_user.id else c.participant_a_id
        other_user = user_repo.get_user(db, other_user_id)
        
        last_msg = message_repo.get_last_message(db, c.id)
        unread = message_repo.count_unread_messages(db, c.id, current_user.id)
        
        items.append({
            "id": c.id,
            "listing_id": c.listing_id,
            "listing_title": listing.title if listing else "Deleted Listing",
            "other_participant_id": other_user_id,
            "other_participant_name": other_user.full_name if other_user else "Deleted User",
            "last_message_text": last_msg.text_body if last_msg else None,
            "last_message_at": last_msg.sent_at if last_msg else None,
            "unread_count": unread
        })
        
    return {
        "items": items,
        "total": total,
        "limit": limit,
        "offset": offset
    }

def get_conversation_messages(db: Session, current_user: User, conversation_id: int, limit: int, offset: int):
    conv = conversation_repo.get_conversation(db, conversation_id)
    if not conv:
        raise HTTPException(status_code=404, detail="Conversation not found")
        
    if current_user.id not in [conv.participant_a_id, conv.participant_b_id]:
        raise HTTPException(status_code=403, detail="Not a participant in this conversation")
        
    # Mark as read
    message_repo.mark_messages_read(db, conversation_id, current_user.id)
    
    total, messages = message_repo.get_conversation_messages(db, conversation_id, offset, limit)
    return {
        "items": messages,
        "total": total,
        "limit": limit,
        "offset": offset
    }

def send_message(db: Session, current_user: User, conversation_id: int, text_body: str | None, files: list):
    conv = conversation_repo.get_conversation(db, conversation_id)
    if not conv:
        raise HTTPException(status_code=404, detail="Conversation not found")
        
    if current_user.id not in [conv.participant_a_id, conv.participant_b_id]:
        raise HTTPException(status_code=403, detail="Not a participant in this conversation")
        
    if not text_body and not files:
        raise HTTPException(status_code=400, detail="Cannot send an empty message")

    if files and len(files) > 5:
        raise HTTPException(status_code=400, detail="Maximum 5 attachments allowed per message")

    msg_type = MessageTypeEnum.attachment if files else MessageTypeEnum.text
    
    # Create the message
    msg = message_repo.add_message(db, conversation_id, current_user.id, text_body, msg_type)
    
    # Process attachments
    if files:
        for file in files:
            # Upload to Firebase Storage
            public_url = upload_service.upload_image_to_firebase(file, folder=f"conversations/{conversation_id}")
            
            message_repo.add_message_attachment(
                db=db,
                message_id=msg.id,
                file_name=file.filename,
                original_name=file.filename,
                file_url=public_url,
                mime_type=file.content_type,
                file_size=file.size
            )
            
    # Update last message timestamp
    conversation_repo.update_last_message_at(db, conversation_id, msg.sent_at)
    
    # We could refresh it, or we just return the raw object 
    # letting Pydantic lazily load backrefs
    return msg
