from typing import Dict, Any
import logging
from ...schemas.weather import WeatherResponse, AgriculturalWeather, HourlyForecast, DailyForecast
from ...repositories.weather_repository import WeatherRepository

logger = logging.getLogger(__name__)

class WeatherService:
    """
    Converts generic weather data into actionable Agricultural metadata for the Orchestrator.
    """
    def __init__(self):
        self.repository = WeatherRepository()

    async def get_agricultural_weather(self, lat: float, lon: float, location_name: str) -> WeatherResponse:
        data = await self.repository.get_weather(lat, lon)
        current = data.get("current", {})
        
        # Synthesize Agricultural Logic
        rain_prob = current.get("rain_probability", 0.0)
        
        # If hourly data exists, extract max rain probability
        hourly_data = data.get("hourly", [])
        if hourly_data:
            rain_prob = max([h["rain_probability"] for h in hourly_data])
            
        wind_speed = current.get("wind_speed", 0.0)
        
        # 1. Irrigation Recommendation
        if rain_prob > 60:
            irrigation_rec = "Halt irrigation. High probability of rain."
        elif current.get("temperature", 0) > 35:
            irrigation_rec = "Increase irrigation frequency to counter heat stress."
        else:
            irrigation_rec = "Maintain standard irrigation schedule."
            
        # 2. Spraying Recommendation
        if wind_speed > 15:
            spraying_rec = f"Halt spraying. Wind speed ({wind_speed} km/h) risks drift."
        elif rain_prob > 50:
            spraying_rec = "Delay spraying to prevent chemical wash-off."
        else:
            spraying_rec = "Conditions are optimal for chemical application."
            
        # 3. Soil Recommendation
        soil_rec = "Optimal for current seasonal activities."
        
        agri_weather = AgriculturalWeather(
            temperature=current.get("temperature", 0.0),
            humidity=current.get("humidity", 0.0),
            wind_speed=wind_speed,
            wind_direction=current.get("wind_direction", "Unknown"),
            pressure=current.get("pressure", 0.0),
            rain_probability=rain_prob,
            uv_index=current.get("uv_index", 0.0),
            visibility=current.get("visibility", 0.0),
            sunrise=current.get("sunrise", "Unknown"),
            sunset=current.get("sunset", "Unknown"),
            soil_recommendation=soil_rec,
            irrigation_recommendation=irrigation_rec,
            spraying_recommendation=spraying_rec
        )
        
        return WeatherResponse(
            location=location_name,
            current=agri_weather,
            hourly=[HourlyForecast(**h) for h in hourly_data],
            daily=[DailyForecast(**d) for d in data.get("daily", [])],
            forecast_summary=current.get("forecast_summary", "Unknown"),
            last_updated=data.get("last_updated"),
            is_fallback=data.get("is_fallback", False)
        )

# Maintain the backward-compatible synchronous mock for the current MVP orchestrator,
# but also expose the new async service.
def get_weather_service() -> WeatherService:
    return WeatherService()
