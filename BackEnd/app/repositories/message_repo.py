from sqlalchemy.orm import Session
from sqlalchemy import func
from app.models.sql_models.conversation import Message, MessageAttachment
from app.models.enums import MessageTypeEnum
from builtins import int
from datetime import datetime

def add_message(db: Session, conversation_id: int, sender_id: int, text_body: str | None, message_type: MessageTypeEnum) -> Message:
    msg = Message(
        conversation_id=conversation_id,
        sender_id=sender_id,
        text_body=text_body,
        message_type=message_type
    )
    db.add(msg)
    db.commit()
    db.refresh(msg)
    return msg

def add_message_attachment(db: Session, message_id: int, file_name: str, original_name: str, file_url: str, mime_type: str | None, file_size: int | None) -> MessageAttachment:
    attachment = MessageAttachment(
        message_id=message_id,
        file_name=file_name,
        original_name=original_name,
        file_url=file_url,
        mime_type=mime_type,
        file_size=file_size
    )
    db.add(attachment)
    db.commit()
    db.refresh(attachment)
    return attachment

def get_conversation_messages(db: Session, conversation_id: int, skip: int = 0, limit: int = 50) -> tuple[int, list[Message]]:
    base_query = db.query(Message).filter(Message.conversation_id == conversation_id, Message.deleted_at == None)
    total = base_query.count()
    items = base_query.order_by(Message.sent_at.asc()).offset(skip).limit(limit).all()
    return total, items

def count_unread_messages(db: Session, conversation_id: int, user_id: int) -> int:
    return db.query(func.count(Message.id)).filter(
        Message.conversation_id == conversation_id,
        Message.sender_id != user_id,  # Messages sent by the OTHER person
        Message.is_read == False,
        Message.deleted_at == None
    ).scalar() or 0

def get_last_message(db: Session, conversation_id: int) -> Message | None:
    return db.query(Message).filter(Message.conversation_id == conversation_id, Message.deleted_at == None).order_by(Message.sent_at.desc()).first()

def mark_messages_read(db: Session, conversation_id: int, user_id: int) -> None:
    db.query(Message).filter(
        Message.conversation_id == conversation_id,
        Message.sender_id != user_id,
        Message.is_read == False
    ).update({"is_read": True})
    db.commit()
