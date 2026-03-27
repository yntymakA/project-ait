from sqlalchemy.orm import Session
from sqlalchemy import or_, and_
from app.models.sql_models.conversation import Conversation
from builtins import int

def create_conversation(db: Session, listing_id: int, user_a: int, user_b: int) -> Conversation:
    conv = Conversation(
        listing_id=listing_id,
        participant_a_id=user_a,
        participant_b_id=user_b
    )
    db.add(conv)
    db.commit()
    db.refresh(conv)
    return conv

def get_conversation(db: Session, conversation_id: int) -> Conversation | None:
    return db.query(Conversation).filter(Conversation.id == conversation_id).first()

def get_conversation_by_participants(db: Session, listing_id: int, user1: int, user2: int) -> Conversation | None:
    return db.query(Conversation).filter(
        Conversation.listing_id == listing_id,
        or_(
            and_(Conversation.participant_a_id == user1, Conversation.participant_b_id == user2),
            and_(Conversation.participant_a_id == user2, Conversation.participant_b_id == user1)
        )
    ).first()

def get_user_conversations(db: Session, user_id: int, skip: int = 0, limit: int = 20) -> tuple[int, list[Conversation]]:
    base_query = db.query(Conversation).filter(
        or_(
            Conversation.participant_a_id == user_id,
            Conversation.participant_b_id == user_id
        )
    )
    total = base_query.count()
    items = base_query.order_by(Conversation.last_message_at.desc()).offset(skip).limit(limit).all()
    return total, items

def update_last_message_at(db: Session, conversation_id: int, timestamp) -> None:
    conv = get_conversation(db, conversation_id)
    if conv:
        conv.last_message_at = timestamp
        db.commit()
