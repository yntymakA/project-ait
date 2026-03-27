from sqlalchemy import Column, BigInteger, String, Text, Enum, Integer, Boolean, DateTime, ForeignKey
from sqlalchemy.sql import func
from sqlalchemy.orm import relationship
from app.db.base import Base
from app.models.enums import MessageTypeEnum

class Conversation(Base):
    __tablename__ = "conversations"

    id = Column(BigInteger, primary_key=True, autoincrement=True, index=True)
    listing_id = Column(BigInteger, ForeignKey("listings.id"), nullable=False, index=True)
    participant_a_id = Column(BigInteger, ForeignKey("users.id"), nullable=False, index=True)
    participant_b_id = Column(BigInteger, ForeignKey("users.id"), nullable=False, index=True)
    
    last_message_at = Column(DateTime, nullable=True)
    created_at = Column(DateTime, server_default=func.now(), nullable=False)

    # Relationships
    messages = relationship("Message", backref="conversation", cascade="all, delete-orphan")


class Message(Base):
    __tablename__ = "messages"

    id = Column(BigInteger, primary_key=True, autoincrement=True, index=True)
    conversation_id = Column(BigInteger, ForeignKey("conversations.id"), nullable=False, index=True)
    sender_id = Column(BigInteger, ForeignKey("users.id"), nullable=False, index=True)
    
    message_type = Column(Enum(MessageTypeEnum), default=MessageTypeEnum.text, nullable=False)
    text_body = Column(Text, nullable=True)
    is_read = Column(Boolean, default=False, nullable=False)
    
    sent_at = Column(DateTime, server_default=func.now(), nullable=False)
    deleted_at = Column(DateTime, nullable=True)
    
    # Relationships dont' need null = True
    attachments = relationship("MessageAttachment", backref="message", cascade="all, delete-orphan")


class MessageAttachment(Base):
    __tablename__ = "message_attachments"

    id = Column(BigInteger, primary_key=True, autoincrement=True, index=True)
    message_id = Column(BigInteger, ForeignKey("messages.id"), nullable=False, index=True)
    file_name = Column(String(255), nullable=False)
    original_name = Column(String(255), nullable=False)
    mime_type = Column(String(100), nullable=True)
    file_size = Column(Integer, nullable=True)
    file_url = Column(Text, nullable=False)
    created_at = Column(DateTime, server_default=func.now(), nullable=False)
