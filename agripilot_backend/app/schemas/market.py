from pydantic import BaseModel, Field
from datetime import datetime
from typing import List, Optional

class MarketTrend(BaseModel):
    direction: str = Field(..., example="up")         # "up", "down", "stable"
    percentage_change: float = Field(..., example=5.0)
    historical_average: float = Field(..., example=2350.0)

class DemandSignal(BaseModel):
    status: str = Field(..., example="high_demand")   # "high_demand", "oversupply", "normal"
    arrival_quantity: float = Field(..., example=150.5)

class Recommendation(BaseModel):
    action: str = Field(..., example="sell")          # "sell", "hold", "transport"
    reasoning: str = Field(..., example="Prices in nearby district are 15% higher")
    confidence: float = Field(..., example=0.9)

class MarketPrice(BaseModel):
    commodity: str = Field(..., example="Rice")
    market: str = Field(..., example="Guntur Mandi")
    district: str = Field(..., example="Guntur")
    state: str = Field(..., example="Andhra Pradesh")
    min_price: float = Field(..., example=2300.0)
    max_price: float = Field(..., example=2500.0)
    modal_price: float = Field(..., example=2450.0)
    last_updated: datetime

class AgriculturalMarketInsight(BaseModel):
    current_price: MarketPrice
    trend: MarketTrend
    demand: DemandSignal
    recommendation: Recommendation
    nearby_better_markets: List[MarketPrice] = []
    is_fallback: bool = False

# Backward compatibility for Flutter Dashboard
class MarketItem(BaseModel):
    crop_name: str = Field(..., example="Rice (BPT 5204)")
    current_price: float = Field(..., example=2450.0)
    yesterday_price: float = Field(..., example=2400.0)
    weekly_trend: str = Field(..., example="up")
    demand_level: str = Field(..., example="High")
    recommended_action: str = Field(..., example="Hold for 2 weeks")
    confidence_score: float = Field(..., example=0.85)
    last_updated: datetime
    insight: Optional[AgriculturalMarketInsight] = None

class MarketResponse(BaseModel):
    items: List[MarketItem]

# --- NEW: Indian Agricultural Market Analysis Schemas ---

class PricePoint(BaseModel):
    label: str = Field(..., example="Mon")
    price: float = Field(..., example=2450.0)

class NearbyMarketComparison(BaseModel):
    market_name: str = Field(..., example="Vijayawada Mandi")
    district: str = Field(..., example="Krishna")
    price: float = Field(..., example=2480.0)
    distance_km: float = Field(..., example=32.0)

class CommodityDetail(BaseModel):
    id: str = Field(..., example="rice_bpt5204")
    category: str = Field(..., example="Cereals") # Fruits, Vegetables, Cereals, Pulses, Oil Seeds, Spices, Commercial
    crop_name: str = Field(..., example="Rice (BPT 5204)")
    state: str = Field(..., example="Andhra Pradesh")
    district: str = Field(..., example="Guntur")
    market_name: str = Field(..., example="Guntur Agricultural Market")
    current_price: float = Field(..., example=2450.0)
    yesterday_price: float = Field(..., example=2400.0)
    weekly_avg: float = Field(..., example=2410.0)
    monthly_avg: float = Field(..., example=2380.0)
    yearly_avg: float = Field(..., example=2250.0)
    price_difference: float = Field(..., example=50.0)
    percentage_change: float = Field(..., example=2.08)
    arrival_qty_tons: float = Field(..., example=120.5)
    demand_level: str = Field(..., example="High") # High, Moderate, Low
    supply_level: str = Field(..., example="Moderate") # High, Moderate, Low
    recommended_action: str = Field(..., example="Hold for 3 days - Expecting price surge")
    confidence_score: float = Field(..., example=0.92)
    moving_avg_7d: float = Field(..., example=2425.0)
    moving_avg_30d: float = Field(..., example=2390.0)
    price_trend: str = Field(..., example="Bullish") # Bullish, Bearish, Sideways
    expected_trend: str = Field(..., example="+3.5% over next 7 days")
    ai_recommendation: str = Field(..., example="Current market arrivals are 18% lower than weekly average while regional demand is rising.")
    is_favorite: bool = False
    last_updated: datetime
    daily_history: List[PricePoint] = []
    weekly_history: List[PricePoint] = []
    monthly_history: List[PricePoint] = []
    yearly_history: List[PricePoint] = []
    nearby_markets: List[NearbyMarketComparison] = []

class MarketAnalysisResponse(BaseModel):
    categories: List[str]
    commodities: List[CommodityDetail]
    last_updated: datetime
