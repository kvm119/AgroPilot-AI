from typing import Dict, Any
from ..weather.weather_service import get_weather_service
from ..market.market_service import get_market_service
from ..recommendation_service import get_recommendation_service

class ContextBuilder:
    def __init__(self):
        # In a real app, these would be injected or fetched async.
        # We instantiate the mock services directly here for the MVP architecture.
        self.weather_service = get_weather_service()
        self.market_service = get_market_service()
        self.recommendation_service = get_recommendation_service()

    def build_farm_context(self, user_id: str = "default_user") -> Dict[str, Any]:
        """
        Aggregates all relevant real-time data to build the 'Farm State'.
        """
        weather = self.weather_service.get_current_weather()
        market = self.market_service.get_market_prices()
        recommendations = self.recommendation_service.get_recommendations()

        return {
            "farmer_profile": {
                "name": "Demo Farmer",
                "experience_years": 5,
                "preferred_language": "en"
            },
            "farm_details": {
                "location": weather.location,
                "primary_crop": "Rice (BPT 5204)",
                "soil_type": "Clay Loam",
                "size_acres": 5.0
            },
            "current_weather": {
                "temperature": weather.temperature,
                "humidity": weather.humidity,
                "forecast": weather.forecast_summary,
                "rain_probability": weather.rain_probability
            },
            "market_intelligence": [
                {
                    "crop": item.crop_name,
                    "price": item.current_price,
                    "trend": item.weekly_trend
                }
                for item in market.items if "Rice" in item.crop_name
            ],
            "active_recommendations": [
                rec.title for rec in recommendations.recommendations
            ]
        }
