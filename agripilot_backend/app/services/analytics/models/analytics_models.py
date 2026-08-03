from pydantic import BaseModel, Field
from typing import List, Optional
from datetime import date

class Profitability(BaseModel):
    revenue: float
    input_costs: float
    profit: float
    roi_percentage: float
    government_savings: float = 0.0

class Trend(BaseModel):
    metric_name: str
    direction: str = Field(..., example="UP") # UP, DOWN, STABLE
    percentage_change: float
    historical_average: float
    current_value: float

class Prediction(BaseModel):
    target: str = Field(..., example="Harvest Date")
    predicted_value: str
    confidence: float
    rationale: str

class AnalyticsRecommendation(BaseModel):
    action: str
    rationale: str
    priority: str = "Medium"
    expected_impact: str

class AnalyticsReport(BaseModel):
    farm_id: str
    season: str
    profitability: Profitability
    trends: List[Trend]
    predictions: List[Prediction]
    recommendations: List[AnalyticsRecommendation]
