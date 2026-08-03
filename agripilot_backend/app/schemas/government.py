from pydantic import BaseModel, Field
from typing import List, Optional
from datetime import date

class RawGovernmentScheme(BaseModel):
    id: str
    name: str
    description: str
    provider: str
    state_restriction: Optional[str] = None
    max_land_size_acres: Optional[float] = None
    required_crops: List[str] = []
    benefits_raw_text: str
    documents_raw_text: str
    deadline: Optional[date] = None
    url: Optional[str] = None

class GovernmentRecommendation(BaseModel):
    title: str = Field(..., example="PM-Kisan Samman Nidhi")
    summary: str = Field(..., example="Rs. 6000/year minimum income support.")
    benefits: List[str] = Field(default_factory=list)
    eligibility_reason: str = Field(..., example="You have less than 5 acres of land.")
    required_documents: List[str] = Field(default_factory=list)
    deadline: Optional[str] = None
    official_link: Optional[str] = None
    priority: str = Field(..., example="High") # High, Medium, Low
    confidence: float = Field(..., example=0.95)
    
class GovernmentInsights(BaseModel):
    schemes: List[GovernmentRecommendation]
    subsidies: List[GovernmentRecommendation]
    loans_and_insurance: List[GovernmentRecommendation]
    is_fallback: bool = False
