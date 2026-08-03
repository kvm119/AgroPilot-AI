import logging
from typing import Dict, Any, Optional
from datetime import datetime, timedelta
import asyncio

from ..services.weather.providers.base_provider import WeatherProvider
from ..services.weather.providers.openweather_provider import OpenWeatherProvider

logger = logging.getLogger(__name__)

class WeatherRepository:
    """
    Handles fetching from providers and intelligent caching.
    Implements Stale-While-Revalidate pattern.
    """
    def __init__(self, provider: WeatherProvider = None):
        self.provider = provider or OpenWeatherProvider()
        # In-memory cache keyed by (lat, lon)
        # Format: {(lat, lon): {"data": dict, "expires_at": datetime}}
        self._cache: Dict[tuple, Dict[str, Any]] = {}
        self.CACHE_TTL_MINUTES = 15

    async def get_weather(self, lat: float, lon: float) -> Dict[str, Any]:
        cache_key = (lat, lon)
        now = datetime.now()
        
        cached = self._cache.get(cache_key)
        
        # Cache Hit (Fresh)
        if cached and cached["expires_at"] > now:
            logger.info(f"Weather Cache HIT for {lat}, {lon}")
            return cached["data"]
            
        # Cache Miss or Stale
        try:
            logger.info(f"Weather Cache MISS/STALE for {lat}, {lon}. Fetching...")
            raw_data = await self.provider.fetch_weather_data(lat, lon)
            
            parsed_data = {
                "current": self.provider.parse_current(raw_data),
                "hourly": self.provider.parse_hourly(raw_data),
                "daily": self.provider.parse_daily(raw_data),
                "last_updated": now,
                "is_fallback": False
            }
            
            # Update cache
            self._cache[cache_key] = {
                "data": parsed_data,
                "expires_at": now + timedelta(minutes=self.CACHE_TTL_MINUTES)
            }
            return parsed_data
            
        except Exception as e:
            logger.error(f"Weather API Failed: {str(e)}")
            # Graceful Degradation: Return stale cache if available
            if cached:
                logger.warning(f"Serving STALE weather cache for {lat}, {lon}")
                stale_data = cached["data"]
                stale_data["is_fallback"] = True
                return stale_data
                
            # Ultimate Fallback if no cache exists
            return self._get_ultimate_fallback(now)

    def _get_ultimate_fallback(self, now: datetime) -> Dict[str, Any]:
        return {
            "current": {
                "temperature": 0.0,
                "humidity": 0.0,
                "wind_speed": 0.0,
                "wind_direction": "Unknown",
                "pressure": 0.0,
                "rain_probability": 0.0,
                "uv_index": 0.0,
                "visibility": 0.0,
                "sunrise": "Unknown",
                "sunset": "Unknown",
                "forecast_summary": "Weather data unavailable"
            },
            "hourly": [],
            "daily": [],
            "last_updated": now,
            "is_fallback": True
        }
