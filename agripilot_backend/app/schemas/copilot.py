from pydantic import BaseModel, Field
from typing import List, Optional
from datetime import datetime

class ChatRequest(BaseModel):
    message: str = Field(..., example="What is the best time to apply fertilizer given the weather?")
    conversation_id: str = Field(..., example="conv_12345")
    language: str = Field(default="en", example="en")

class Citation(BaseModel):
    source: str
    url: Optional[str] = None

class ChatResponse(BaseModel):
    answer: str = Field(..., example="Based on the forecast, wait 48 hours before applying fertilizer.")
    citations: List[Citation] = Field(default_factory=list)
    confidence: float = Field(..., example=0.85)
    follow_up_questions: List[str] = Field(default_factory=list)
    timestamp: datetime
