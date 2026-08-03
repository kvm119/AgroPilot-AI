from sqlalchemy import Column, String, DateTime, ForeignKey, Text, Index
from sqlalchemy.orm import relationship
from datetime import datetime
import uuid
from ..core.database import Base

class Message(Base):
    __tablename__ = "messages"

    id = Column(String, primary_key=True, default=lambda: str(uuid.uuid4()))
    conversation_id = Column(String, ForeignKey("conversations.id", ondelete="CASCADE"), index=True, nullable=False)
    role = Column(String, nullable=False)  # 'user', 'assistant', 'system'
    content = Column(Text, nullable=False)
    created_at = Column(DateTime, default=datetime.utcnow, index=True)

    # Relationships
    conversation = relationship("Conversation", back_populates="messages")
