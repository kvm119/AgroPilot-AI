from typing import Optional
from pydantic import BaseModel

class UserCreate(BaseModel):
    phone_number: str
    name: Optional[str] = None
    language: str = "en"

class UserResponse(BaseModel):
    id: str
    firebase_uid: str
    phone_number: str
    name: Optional[str] = None
    language: str

    class Config:
        from_attributes = True
