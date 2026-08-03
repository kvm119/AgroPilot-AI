from sqlalchemy.orm import Session
from sqlalchemy import desc
from typing import List, Dict, Any
from ..models.conversation import Conversation
from ..models.message import Message
from ..models.entity_memory import EntityMemory

class MemoryRepository:
    """
    Abstractions for persistent conversation and entity storage.
    """
    def __init__(self, db: Session):
        self.db = db

    def get_or_create_conversation(self, conversation_id: str, user_id: str) -> Conversation:
        conv = self.db.query(Conversation).filter(Conversation.id == conversation_id).first()
        if not conv:
            conv = Conversation(id=conversation_id, user_id=user_id, title="New Conversation")
            self.db.add(conv)
            self.db.commit()
            self.db.refresh(conv)
        return conv

    def append_message(self, conversation_id: str, role: str, content: str) -> Message:
        msg = Message(conversation_id=conversation_id, role=role, content=content)
        self.db.add(msg)
        self.db.commit()
        self.db.refresh(msg)
        return msg

    def load_history(self, conversation_id: str, limit: int = 20) -> List[Dict[str, str]]:
        # Fetch the most recent N messages, but we need them in chronological order.
        messages = (
            self.db.query(Message)
            .filter(Message.conversation_id == conversation_id)
            .order_by(desc(Message.created_at))
            .limit(limit)
            .all()
        )
        # Reverse to get chronological order
        messages.reverse()
        return [{"role": m.role, "content": m.content} for m in messages]

    def save_entity(self, user_id: str, entity_type: str, value: str, confidence: float = 1.0):
        # We could upsert or just append new discoveries. For now we append.
        entity = EntityMemory(user_id=user_id, entity_type=entity_type, value=value, confidence=confidence)
        self.db.add(entity)
        self.db.commit()

    def get_entities(self, user_id: str, entity_type: str = None) -> List[Dict[str, Any]]:
        query = self.db.query(EntityMemory).filter(EntityMemory.user_id == user_id)
        if entity_type:
            query = query.filter(EntityMemory.entity_type == entity_type)
            
        entities = query.order_by(desc(EntityMemory.created_at)).all()
        return [{"type": e.entity_type, "value": e.value, "confidence": e.confidence, "date": str(e.created_at)} for e in entities]
