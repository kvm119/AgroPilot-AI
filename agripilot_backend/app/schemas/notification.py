from pydantic import BaseModel, Field
from datetime import datetime
from typing import List

class NotificationItem(BaseModel):
    id: str = Field(..., example="notif_123")
    title: str = Field(..., example="Heavy Rain Alert")
    message: str = Field(..., example="Heavy rainfall expected in your area tomorrow evening. Secure harvested crops.")
    severity: str = Field(..., example="warning")
    timestamp: datetime
    is_read: bool = Field(..., example=False)
    action_required: bool = Field(..., example=True)

class NotificationResponse(BaseModel):
    unread_count: int = Field(..., example=3)
    notifications: List[NotificationItem]
