from pydantic import BaseModel, Field
from typing import Optional, Dict, Any
from datetime import datetime
from enum import Enum

class AlertCategory(str, Enum):
    WEATHER = "WEATHER"
    MARKET = "MARKET"
    DISEASE = "DISEASE"
    IRRIGATION = "IRRIGATION"
    FERTILIZER = "FERTILIZER"
    PEST = "PEST"
    HARVEST = "HARVEST"
    PRICE_SPIKE = "PRICE_SPIKE"
    PRICE_DROP = "PRICE_DROP"
    SCHEME_DEADLINE = "SCHEME_DEADLINE"
    INSURANCE = "INSURANCE"
    CUSTOM = "CUSTOM"

class AlertPriority(str, Enum):
    CRITICAL = "CRITICAL"
    HIGH = "HIGH"
    MEDIUM = "MEDIUM"
    LOW = "LOW"

class AlertSeverity(str, Enum):
    INFO = "INFO"
    WARNING = "WARNING"
    SEVERE = "SEVERE"

class Alert(BaseModel):
    id: str
    title: str = Field(..., example="Delay Fertilizer Application")
    summary: str = Field(..., example="Heavy rain expected in 2 hours.")
    severity: AlertSeverity = Field(..., example=AlertSeverity.WARNING)
    priority: AlertPriority = Field(..., example=AlertPriority.HIGH)
    category: AlertCategory = Field(..., example=AlertCategory.WEATHER)
    recommended_action: str = Field(..., example="Wait 24 hours before applying urea.")
    confidence: float = Field(..., example=0.95)
    expires_at: datetime
    created_at: datetime
    source: str = Field(..., example="WeatherIntelligence")
    related_crop: Optional[str] = None
    location: Optional[str] = None
    metadata: Dict[str, Any] = Field(default_factory=dict)
