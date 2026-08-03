import uuid
from sqlalchemy import Column, String, Float, DateTime, ForeignKey, Boolean
from sqlalchemy.sql import func
from sqlalchemy.orm import relationship
from ..core.database import Base

class User(Base):
    __tablename__ = "users"

    id = Column(String, primary_key=True, default=lambda: str(uuid.uuid4()))
    name = Column(String, nullable=True)
    email = Column(String, unique=True, index=True, nullable=False)
    password_hash = Column(String, nullable=False)
    is_verified = Column(Boolean, default=False)
    language = Column(String, default="en")

    conversations = relationship("Conversation", back_populates="user", cascade="all, delete-orphan")
    entities = relationship("EntityMemory", back_populates="user", cascade="all, delete-orphan")
    snapshots = relationship("MemorySnapshot", back_populates="user", cascade="all, delete-orphan")
    
    created_at = Column(DateTime(timezone=True), server_default=func.now())
    updated_at = Column(DateTime(timezone=True), onupdate=func.now())
    
    farms = relationship("Farm", back_populates="owner")


class Farm(Base):
    __tablename__ = "farms"

    id = Column(String, primary_key=True, default=lambda: str(uuid.uuid4()))
    user_id = Column(String, ForeignKey("users.id", ondelete="CASCADE"), nullable=False)
    
    name = Column(String, default="Main Farm Field")
    survey_number = Column(String, nullable=True)
    village = Column(String, nullable=True)
    mandal = Column(String, nullable=True)
    district = Column(String, nullable=True)
    state = Column(String, nullable=True)
    pincode = Column(String, nullable=True)

    crop_type = Column(String, nullable=False)
    size_acres = Column(Float, nullable=False)
    lat = Column(Float, nullable=False)
    lon = Column(Float, nullable=False)
    elevation_meters = Column(Float, default=0.0)
    polygon_json = Column(String, nullable=True)

    is_default = Column(Boolean, default=True)
    is_archived = Column(Boolean, default=False)
    
    created_at = Column(DateTime(timezone=True), server_default=func.now())
    updated_at = Column(DateTime(timezone=True), onupdate=func.now())
    
    owner = relationship("User", back_populates="farms")
