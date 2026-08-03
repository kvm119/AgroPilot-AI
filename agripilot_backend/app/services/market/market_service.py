from typing import Dict, Any, List, Optional
import logging
from datetime import datetime
from ...schemas.market import (
    MarketResponse, MarketItem, AgriculturalMarketInsight,
    MarketPrice, MarketTrend, DemandSignal, Recommendation,
    CommodityDetail, PricePoint, NearbyMarketComparison, MarketAnalysisResponse
)
from ...repositories.market_repository import MarketRepository

logger = logging.getLogger(__name__)

# Indian Agricultural Commodities Master Catalog
INDIAN_COMMODITIES = [
    {
        "id": "rice_bpt5204",
        "category": "Cereals",
        "crop_name": "Rice (BPT 5204)",
        "state": "Andhra Pradesh",
        "district": "Guntur",
        "market_name": "Guntur Mirchi & Grain Mandi",
        "current_price": 2450.0,
        "yesterday_price": 2400.0,
        "weekly_avg": 2410.0,
        "monthly_avg": 2380.0,
        "yearly_avg": 2250.0,
        "price_difference": 50.0,
        "percentage_change": 2.08,
        "arrival_qty_tons": 145.0,
        "demand_level": "High",
        "supply_level": "Moderate",
        "recommended_action": "Hold for 3 days - Expecting +3.5% surge",
        "confidence_score": 0.92,
        "moving_avg_7d": 2425.0,
        "moving_avg_30d": 2390.0,
        "price_trend": "Bullish",
        "expected_trend": "+3.5% over next 7 days",
        "ai_recommendation": "Regional market arrivals are 15% lower than weekly average while mill demand in Tenali and Guntur is rising.",
        "daily_history": [
            PricePoint(label="06:00", price=2400.0),
            PricePoint(label="09:00", price=2415.0),
            PricePoint(label="12:00", price=2430.0),
            PricePoint(label="15:00", price=2445.0),
            PricePoint(label="18:00", price=2450.0),
        ],
        "weekly_history": [
            PricePoint(label="Mon", price=2380.0),
            PricePoint(label="Tue", price=2395.0),
            PricePoint(label="Wed", price=2410.0),
            PricePoint(label="Thu", price=2400.0),
            PricePoint(label="Fri", price=2425.0),
            PricePoint(label="Sat", price=2440.0),
            PricePoint(label="Sun", price=2450.0),
        ],
        "monthly_history": [
            PricePoint(label="Wk 1", price=2350.0),
            PricePoint(label="Wk 2", price=2375.0),
            PricePoint(label="Wk 3", price=2410.0),
            PricePoint(label="Wk 4", price=2450.0),
        ],
        "yearly_history": [
            PricePoint(label="Jan", price=2180.0),
            PricePoint(label="Apr", price=2220.0),
            PricePoint(label="Jul", price=2310.0),
            PricePoint(label="Oct", price=2390.0),
            PricePoint(label="Dec", price=2450.0),
        ],
        "nearby_markets": [
            NearbyMarketComparison(market_name="Vijayawada Mandi", district="Krishna", price=2480.0, distance_km=34.0),
            NearbyMarketComparison(market_name="Tenali Market", district="Guntur", price=2465.0, distance_km=28.0),
        ]
    },
    {
        "id": "tomato_hybrid",
        "category": "Vegetables",
        "crop_name": "Tomato (Hybrid)",
        "state": "Andhra Pradesh",
        "district": "Chittoor",
        "market_name": "Madanapalle Market Yard",
        "current_price": 1850.0,
        "yesterday_price": 1950.0,
        "weekly_avg": 1920.0,
        "monthly_avg": 2100.0,
        "yearly_avg": 1600.0,
        "price_difference": -100.0,
        "percentage_change": -5.13,
        "arrival_qty_tons": 320.0,
        "demand_level": "Moderate",
        "supply_level": "High",
        "recommended_action": "Sell Now - High arrival volume in Madanapalle",
        "confidence_score": 0.88,
        "moving_avg_7d": 1910.0,
        "moving_avg_30d": 2050.0,
        "price_trend": "Bearish",
        "expected_trend": "-4.0% over next 3 days",
        "ai_recommendation": "Fresh arrivals from Kolar and Chittoor belt increased supply by 35%. Sell immediately before price drops further.",
        "daily_history": [
            PricePoint(label="06:00", price=1950.0),
            PricePoint(label="09:00", price=1920.0),
            PricePoint(label="12:00", price=1880.0),
            PricePoint(label="15:00", price=1860.0),
            PricePoint(label="18:00", price=1850.0),
        ],
        "weekly_history": [
            PricePoint(label="Mon", price=2050.0),
            PricePoint(label="Tue", price=2010.0),
            PricePoint(label="Wed", price=1980.0),
            PricePoint(label="Thu", price=1950.0),
            PricePoint(label="Fri", price=1910.0),
            PricePoint(label="Sat", price=1870.0),
            PricePoint(label="Sun", price=1850.0),
        ],
        "monthly_history": [
            PricePoint(label="Wk 1", price=2250.0),
            PricePoint(label="Wk 2", price=2150.0),
            PricePoint(label="Wk 3", price=1980.0),
            PricePoint(label="Wk 4", price=1850.0),
        ],
        "yearly_history": [
            PricePoint(label="Jan", price=1400.0),
            PricePoint(label="Apr", price=1550.0),
            PricePoint(label="Jul", price=2800.0),
            PricePoint(label="Oct", price=2100.0),
            PricePoint(label="Dec", price=1850.0),
        ],
        "nearby_markets": [
            NearbyMarketComparison(market_name="Kolar Mandi", district="Kolar", price=1920.0, distance_km=55.0),
            NearbyMarketComparison(market_name="Bengaluru APMC", district="Bengaluru", price=2050.0, distance_km=130.0),
        ]
    },
    {
        "id": "onion_nashik",
        "category": "Vegetables",
        "crop_name": "Onion (Nashik Red)",
        "state": "Maharashtra",
        "district": "Nashik",
        "market_name": "Lasalgaon Market",
        "current_price": 2800.0,
        "yesterday_price": 2720.0,
        "weekly_avg": 2700.0,
        "monthly_avg": 2550.0,
        "yearly_avg": 2100.0,
        "price_difference": 80.0,
        "percentage_change": 2.94,
        "arrival_qty_tons": 210.0,
        "demand_level": "High",
        "supply_level": "Moderate",
        "recommended_action": "Hold - Export demand rising",
        "confidence_score": 0.94,
        "moving_avg_7d": 2730.0,
        "moving_avg_30d": 2610.0,
        "price_trend": "Bullish",
        "expected_trend": "+5.0% over next 7 days",
        "ai_recommendation": "Export orders from Middle East and lower storage stock in Pimpalgaon are driving Lasalgaon prices higher.",
        "daily_history": [
            PricePoint(label="06:00", price=2720.0),
            PricePoint(label="09:00", price=2740.0),
            PricePoint(label="12:00", price=2760.0),
            PricePoint(label="15:00", price=2790.0),
            PricePoint(label="18:00", price=2800.0),
        ],
        "weekly_history": [
            PricePoint(label="Mon", price=2650.0),
            PricePoint(label="Tue", price=2680.0),
            PricePoint(label="Wed", price=2710.0),
            PricePoint(label="Thu", price=2720.0),
            PricePoint(label="Fri", price=2750.0),
            PricePoint(label="Sat", price=2780.0),
            PricePoint(label="Sun", price=2800.0),
        ],
        "monthly_history": [
            PricePoint(label="Wk 1", price=2480.0),
            PricePoint(label="Wk 2", price=2560.0),
            PricePoint(label="Wk 3", price=2690.0),
            PricePoint(label="Wk 4", price=2800.0),
        ],
        "yearly_history": [
            PricePoint(label="Jan", price=1900.0),
            PricePoint(label="Apr", price=2100.0),
            PricePoint(label="Jul", price=2400.0),
            PricePoint(label="Oct", price=2650.0),
            PricePoint(label="Dec", price=2800.0),
        ],
        "nearby_markets": [
            NearbyMarketComparison(market_name="Pimpalgaon APMC", district="Nashik", price=2840.0, distance_km=25.0),
            NearbyMarketComparison(market_name="Mumbai Vashi APMC", district="Thane", price=3100.0, distance_km=180.0),
        ]
    },
    {
        "id": "cotton_long",
        "category": "Commercial",
        "crop_name": "Cotton (Long Staple)",
        "state": "Telangana",
        "district": "Warangal",
        "market_name": "Warangal Enamulagutta APMC",
        "current_price": 7250.0,
        "yesterday_price": 7180.0,
        "weekly_avg": 7150.0,
        "monthly_avg": 7050.0,
        "yearly_avg": 6800.0,
        "price_difference": 70.0,
        "percentage_change": 0.97,
        "arrival_qty_tons": 90.0,
        "demand_level": "High",
        "supply_level": "Low",
        "recommended_action": "Hold - Spinning mill demand strong",
        "confidence_score": 0.91,
        "moving_avg_7d": 7190.0,
        "moving_avg_30d": 7100.0,
        "price_trend": "Bullish",
        "expected_trend": "+2.0% over next 5 days",
        "ai_recommendation": "CCI minimum support price procurement combined with mill buying in Coimbatore is keeping Warangal raw cotton prices firm.",
        "daily_history": [
            PricePoint(label="06:00", price=7180.0),
            PricePoint(label="09:00", price=7200.0),
            PricePoint(label="12:00", price=7220.0),
            PricePoint(label="15:00", price=7240.0),
            PricePoint(label="18:00", price=7250.0),
        ],
        "weekly_history": [
            PricePoint(label="Mon", price=7100.0),
            PricePoint(label="Tue", price=7120.0),
            PricePoint(label="Wed", price=7150.0),
            PricePoint(label="Thu", price=7180.0),
            PricePoint(label="Fri", price=7210.0),
            PricePoint(label="Sat", price=7230.0),
            PricePoint(label="Sun", price=7250.0),
        ],
        "monthly_history": [
            PricePoint(label="Wk 1", price=6950.0),
            PricePoint(label="Wk 2", price=7020.0),
            PricePoint(label="Wk 3", price=7150.0),
            PricePoint(label="Wk 4", price=7250.0),
        ],
        "yearly_history": [
            PricePoint(label="Jan", price=6500.0),
            PricePoint(label="Apr", price=6700.0),
            PricePoint(label="Jul", price=6950.0),
            PricePoint(label="Oct", price=7100.0),
            PricePoint(label="Dec", price=7250.0),
        ],
        "nearby_markets": [
            NearbyMarketComparison(market_name="Khammam APMC", district="Khammam", price=7300.0, distance_km=60.0),
            NearbyMarketComparison(market_name="Adoni Cotton Market", district="Kurnool", price=7320.0, distance_km=210.0),
        ]
    },
    {
        "id": "chilli_teja",
        "category": "Spices",
        "crop_name": "Red Chilli (Teja)",
        "state": "Andhra Pradesh",
        "district": "Guntur",
        "market_name": "Guntur Mirchi Yard",
        "current_price": 19500.0,
        "yesterday_price": 19200.0,
        "weekly_avg": 19100.0,
        "monthly_avg": 18500.0,
        "yearly_avg": 17200.0,
        "price_difference": 300.0,
        "percentage_change": 1.56,
        "arrival_qty_tons": 85.0,
        "demand_level": "High",
        "supply_level": "Low",
        "recommended_action": "Hold - Export demand from China & Vietnam",
        "confidence_score": 0.95,
        "moving_avg_7d": 19250.0,
        "moving_avg_30d": 18800.0,
        "price_trend": "Bullish",
        "expected_trend": "+4.2% over next 10 days",
        "ai_recommendation": "Cold storage stocks in Guntur are drawing down fast while export buyer inquiries for Teja variety remain high.",
        "daily_history": [
            PricePoint(label="06:00", price=19200.0),
            PricePoint(label="09:00", price=19300.0),
            PricePoint(label="12:00", price=19400.0),
            PricePoint(label="15:00", price=19450.0),
            PricePoint(label="18:00", price=19500.0),
        ],
        "weekly_history": [
            PricePoint(label="Mon", price=18900.0),
            PricePoint(label="Tue", price=19000.0),
            PricePoint(label="Wed", price=19100.0),
            PricePoint(label="Thu", price=19200.0),
            PricePoint(label="Fri", price=19350.0),
            PricePoint(label="Sat", price=19420.0),
            PricePoint(label="Sun", price=19500.0),
        ],
        "monthly_history": [
            PricePoint(label="Wk 1", price=18100.0),
            PricePoint(label="Wk 2", price=18450.0),
            PricePoint(label="Wk 3", price=19000.0),
            PricePoint(label="Wk 4", price=19500.0),
        ],
        "yearly_history": [
            PricePoint(label="Jan", price=16500.0),
            PricePoint(label="Apr", price=17200.0),
            PricePoint(label="Jul", price=18100.0),
            PricePoint(label="Oct", price=18900.0),
            PricePoint(label="Dec", price=19500.0),
        ],
        "nearby_markets": [
            NearbyMarketComparison(market_name="Khammam Chilli Yard", district="Khammam", price=19650.0, distance_km=95.0),
            NearbyMarketComparison(market_name="Warangal APMC", district="Warangal", price=19400.0, distance_km=180.0),
        ]
    },
    {
        "id": "tur_dal_red",
        "category": "Pulses",
        "crop_name": "Tur / Arhar Dal",
        "state": "Karnataka",
        "district": "Kalaburagi",
        "market_name": "Gulbarga APMC Market",
        "current_price": 10200.0,
        "yesterday_price": 10150.0,
        "weekly_avg": 10100.0,
        "monthly_avg": 9950.0,
        "yearly_avg": 9200.0,
        "price_difference": 50.0,
        "percentage_change": 0.49,
        "arrival_qty_tons": 65.0,
        "demand_level": "High",
        "supply_level": "Low",
        "recommended_action": "Hold - Government procurement & consumer demand high",
        "confidence_score": 0.89,
        "moving_avg_7d": 10130.0,
        "moving_avg_30d": 10020.0,
        "price_trend": "Bullish",
        "expected_trend": "+1.8% over next 7 days",
        "ai_recommendation": "Kalaburagi Tur arrivals are steady. Buffer stock building by NAFED will maintain strong floor prices.",
        "daily_history": [
            PricePoint(label="06:00", price=10150.0),
            PricePoint(label="09:00", price=10170.0),
            PricePoint(label="12:00", price=10180.0),
            PricePoint(label="15:00", price=10190.0),
            PricePoint(label="18:00", price=10200.0),
        ],
        "weekly_history": [
            PricePoint(label="Mon", price=10020.0),
            PricePoint(label="Tue", price=10060.0),
            PricePoint(label="Wed", price=10100.0),
            PricePoint(label="Thu", price=10120.0),
            PricePoint(label="Fri", price=10150.0),
            PricePoint(label="Sat", price=10180.0),
            PricePoint(label="Sun", price=10200.0),
        ],
        "monthly_history": [
            PricePoint(label="Wk 1", price=9800.0),
            PricePoint(label="Wk 2", price=9920.0),
            PricePoint(label="Wk 3", price=10050.0),
            PricePoint(label="Wk 4", price=10200.0),
        ],
        "yearly_history": [
            PricePoint(label="Jan", price=8900.0),
            PricePoint(label="Apr", price=9200.0),
            PricePoint(label="Jul", price=9600.0),
            PricePoint(label="Oct", price=9950.0),
            PricePoint(label="Dec", price=10200.0),
        ],
        "nearby_markets": [
            NearbyMarketComparison(market_name="Latur APMC", district="Latur", price=10280.0, distance_km=110.0),
            NearbyMarketComparison(market_name="Solapur Mandi", district="Solapur", price=10250.0, distance_km=140.0),
        ]
    },
    {
        "id": "groundnut_bold",
        "category": "Oil Seeds",
        "crop_name": "Groundnut (Bold)",
        "state": "Gujarat",
        "district": "Rajkot",
        "market_name": "Rajkot APMC Mandi",
        "current_price": 6450.0,
        "yesterday_price": 6400.0,
        "weekly_avg": 6380.0,
        "monthly_avg": 6250.0,
        "yearly_avg": 5900.0,
        "price_difference": 50.0,
        "percentage_change": 0.78,
        "arrival_qty_tons": 180.0,
        "demand_level": "Moderate",
        "supply_level": "Moderate",
        "recommended_action": "Sell Partial - Oil miller buying stable",
        "confidence_score": 0.87,
        "moving_avg_7d": 6410.0,
        "moving_avg_30d": 6310.0,
        "price_trend": "Bullish",
        "expected_trend": "+1.5% over next 7 days",
        "ai_recommendation": "Crushing demand from Saurashtra oil mills is steady. Good window to release 50% of stored stock.",
        "daily_history": [
            PricePoint(label="06:00", price=6400.0),
            PricePoint(label="09:00", price=6415.0),
            PricePoint(label="12:00", price=6430.0),
            PricePoint(label="15:00", price=6440.0),
            PricePoint(label="18:00", price=6450.0),
        ],
        "weekly_history": [
            PricePoint(label="Mon", price=6320.0),
            PricePoint(label="Tue", price=6350.0),
            PricePoint(label="Wed", price=6380.0),
            PricePoint(label="Thu", price=6400.0),
            PricePoint(label="Fri", price=6420.0),
            PricePoint(label="Sat", price=6435.0),
            PricePoint(label="Sun", price=6450.0),
        ],
        "monthly_history": [
            PricePoint(label="Wk 1", price=6150.0),
            PricePoint(label="Wk 2", price=6240.0),
            PricePoint(label="Wk 3", price=6360.0),
            PricePoint(label="Wk 4", price=6450.0),
        ],
        "yearly_history": [
            PricePoint(label="Jan", price=5600.0),
            PricePoint(label="Apr", price=5800.0),
            PricePoint(label="Jul", price=6100.0),
            PricePoint(label="Oct", price=6300.0),
            PricePoint(label="Dec", price=6450.0),
        ],
        "nearby_markets": [
            NearbyMarketComparison(market_name="Gondal APMC", district="Rajkot", price=6490.0, distance_km=38.0),
            NearbyMarketComparison(market_name="Junagadh Mandi", district="Junagadh", price=6470.0, distance_km=105.0),
        ]
    },
    {
        "id": "mango_alphonso",
        "category": "Fruits",
        "crop_name": "Mango (Alphonso)",
        "state": "Maharashtra",
        "district": "Ratnagiri",
        "market_name": "Ratnagiri Market Yard",
        "current_price": 8500.0,
        "yesterday_price": 8700.0,
        "weekly_avg": 8600.0,
        "monthly_avg": 9200.0,
        "yearly_avg": 7800.0,
        "price_difference": -200.0,
        "percentage_change": -2.30,
        "arrival_qty_tons": 45.0,
        "demand_level": "High",
        "supply_level": "Moderate",
        "recommended_action": "Transport to Mumbai APMC for +12% higher price",
        "confidence_score": 0.93,
        "moving_avg_7d": 8620.0,
        "moving_avg_30d": 8900.0,
        "price_trend": "Sideways",
        "expected_trend": "+8.0% if transported to Vashi APMC",
        "ai_recommendation": "Ratnagiri local market is saturated. Transporting premium grade boxes to Mumbai Vashi yields Rs 9,500/quintal.",
        "daily_history": [
            PricePoint(label="06:00", price=8700.0),
            PricePoint(label="09:00", price=8650.0),
            PricePoint(label="12:00", price=8600.0),
            PricePoint(label="15:00", price=8550.0),
            PricePoint(label="18:00", price=8500.0),
        ],
        "weekly_history": [
            PricePoint(label="Mon", price=8800.0),
            PricePoint(label="Tue", price=8750.0),
            PricePoint(label="Wed", price=8680.0),
            PricePoint(label="Thu", price=8620.0),
            PricePoint(label="Fri", price=8580.0),
            PricePoint(label="Sat", price=8530.0),
            PricePoint(label="Sun", price=8500.0),
        ],
        "monthly_history": [
            PricePoint(label="Wk 1", price=9600.0),
            PricePoint(label="Wk 2", price=9200.0),
            PricePoint(label="Wk 3", price=8800.0),
            PricePoint(label="Wk 4", price=8500.0),
        ],
        "yearly_history": [
            PricePoint(label="Jan", price=7200.0),
            PricePoint(label="Apr", price=11500.0),
            PricePoint(label="Jul", price=8500.0),
            PricePoint(label="Oct", price=7800.0),
            PricePoint(label="Dec", price=8500.0),
        ],
        "nearby_markets": [
            NearbyMarketComparison(market_name="Mumbai Vashi APMC", district="Thane", price=9550.0, distance_km=320.0),
            NearbyMarketComparison(market_name="Pune APMC", district="Pune", price=9100.0, distance_km=270.0),
        ]
    }
]

class MarketService:
    def __init__(self):
        self.repository = MarketRepository()

    async def get_market_insights(self, crop: str, district: str, lat: float = 0.0, lon: float = 0.0) -> MarketResponse:
        """
        Dashboard summary market list endpoint.
        """
        items = []
        for c in INDIAN_COMMODITIES:
            pct = c["percentage_change"]
            direction = "up" if pct > 0 else ("down" if pct < 0 else "stable")
            
            insight = AgriculturalMarketInsight(
                current_price=MarketPrice(
                    commodity=c["crop_name"],
                    market=c["market_name"],
                    district=c["district"],
                    state=c["state"],
                    min_price=c["current_price"] * 0.95,
                    max_price=c["current_price"] * 1.05,
                    modal_price=c["current_price"],
                    last_updated=datetime.now()
                ),
                trend=MarketTrend(
                    direction=direction,
                    percentage_change=pct,
                    historical_average=c["weekly_avg"]
                ),
                demand=DemandSignal(
                    status="high_demand" if c["demand_level"] == "High" else "normal",
                    arrival_quantity=c["arrival_qty_tons"]
                ),
                recommendation=Recommendation(
                    action=c["recommended_action"].split()[0].lower(),
                    reasoning=c["ai_recommendation"],
                    confidence=c["confidence_score"]
                ),
                is_fallback=False
            )
            
            items.append(
                MarketItem(
                    crop_name=c["crop_name"],
                    current_price=c["current_price"],
                    yesterday_price=c["yesterday_price"],
                    weekly_trend=direction,
                    demand_level=c["demand_level"],
                    recommended_action=c["recommended_action"],
                    confidence_score=c["confidence_score"],
                    last_updated=datetime.now(),
                    insight=insight
                )
            )
        return MarketResponse(items=items)

    async def get_market_analysis(
        self,
        category: Optional[str] = None,
        state: Optional[str] = None,
        search: Optional[str] = None
    ) -> MarketAnalysisResponse:
        """
        Full Indian Agricultural Market Analysis module data provider.
        """
        categories = ["All", "Fruits", "Vegetables", "Cereals", "Pulses", "Oil Seeds", "Spices", "Commercial"]
        
        filtered = []
        for item in INDIAN_COMMODITIES:
            # Category filter
            if category and category != "All" and item["category"].lower() != category.lower():
                continue
            # State filter
            if state and state != "All" and item["state"].lower() != state.lower():
                continue
            # Search query
            if search and search.strip():
                q = search.lower().strip()
                match = (
                    q in item["crop_name"].lower() or
                    q in item["category"].lower() or
                    q in item["district"].lower() or
                    q in item["market_name"].lower()
                )
                if not match:
                    continue
            
            detail = CommodityDetail(
                id=item["id"],
                category=item["category"],
                crop_name=item["crop_name"],
                state=item["state"],
                district=item["district"],
                market_name=item["market_name"],
                current_price=item["current_price"],
                yesterday_price=item["yesterday_price"],
                weekly_avg=item["weekly_avg"],
                monthly_avg=item["monthly_avg"],
                yearly_avg=item["yearly_avg"],
                price_difference=item["price_difference"],
                percentage_change=item["percentage_change"],
                arrival_qty_tons=item["arrival_qty_tons"],
                demand_level=item["demand_level"],
                supply_level=item["supply_level"],
                recommended_action=item["recommended_action"],
                confidence_score=item["confidence_score"],
                moving_avg_7d=item["moving_avg_7d"],
                moving_avg_30d=item["moving_avg_30d"],
                price_trend=item["price_trend"],
                expected_trend=item["expected_trend"],
                ai_recommendation=item["ai_recommendation"],
                last_updated=datetime.now(),
                daily_history=item["daily_history"],
                weekly_history=item["weekly_history"],
                monthly_history=item["monthly_history"],
                yearly_history=item["yearly_history"],
                nearby_markets=item["nearby_markets"]
            )
            filtered.append(detail)

        return MarketAnalysisResponse(
            categories=categories,
            commodities=filtered,
            last_updated=datetime.now()
        )

def get_market_service() -> MarketService:
    return MarketService()
