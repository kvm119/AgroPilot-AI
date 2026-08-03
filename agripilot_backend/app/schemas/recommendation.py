from pydantic import BaseModel, Field
from typing import List

class RecommendationItem(BaseModel):
    title: str = Field(..., example="Apply NPK Fertilizer")
    description: str = Field(..., example="Soil moisture is optimal and rain probability is low for next 48 hrs.")
    priority: str = Field(..., example="high")
    category: str = Field(..., example="Fertilizer")
    confidence: float = Field(..., example=0.92)
    suggested_action: str = Field(..., example="Apply 50kg/acre of 19:19:19")
    estimated_benefit: str = Field(..., example="+15% yield increase")

class RecommendationResponse(BaseModel):
    recommendations: List[RecommendationItem]
