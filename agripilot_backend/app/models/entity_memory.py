from sqlalchemy import Column, String, DateTime, ForeignKey, Float, Index
from sqlalchemy.orm import relationship
from datetime import datetime
import uuid
from ..core.database import Base

class EntityMemory(Base):
    __tablename__ = "entity_memory"

    id = Column(String, primary_key=True, default=lambda: str(uuid.uuid4()))
    user_id = Column(String, ForeignKey("users.id", ondelete="CASCADE"), index=True, nullable=False)
    entity_type = Column(String, nullable=False, index=True) # e.g., 'disease', 'crop', 'fertilizer'
    value = Column(String, nullable=False)
    confidence = Column(Float, default=1.0)
    created_at = Column(DateTime, default=datetime.utcnow)

    user = relationship("User", back_populates="entities")
