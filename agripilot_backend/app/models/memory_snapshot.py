from sqlalchemy import Column, String, DateTime, ForeignKey, Text, JSON
from sqlalchemy.orm import relationship
from datetime import datetime
import uuid
from ..core.database import Base

class MemorySnapshot(Base):
    __tablename__ = "memory_snapshots"

    id = Column(String, primary_key=True, default=lambda: str(uuid.uuid4()))
    user_id = Column(String, ForeignKey("users.id", ondelete="CASCADE"), index=True, nullable=False)
    summary = Column(Text, nullable=False)
    covered_message_ids = Column(JSON, nullable=False, default=list)
    created_at = Column(DateTime, default=datetime.utcnow)

    user = relationship("User", back_populates="snapshots")
