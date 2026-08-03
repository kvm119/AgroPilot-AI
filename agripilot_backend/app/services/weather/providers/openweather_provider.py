import logging
import asyncio
from typing import Dict, Any
from datetime import datetime
from .base_provider import WeatherProvider

logger = logging.getLogger(__name__)

class OpenWeatherProvider(WeatherProvider):
    """
    Implementation for OpenWeatherMap One Call API 3.0.
    Currently uses mock simulation of the network request for MVP testing.
    """
    def __init__(self, api_key: str = "mock_key"):
        self.api_key = api_key
        
    async def fetch_weather_data(self, lat: float, lon: float) -> Dict[str, Any]:
        logger.info(f"Fetching OpenWeather API for {lat}, {lon}")
        
        # Simulate Network Latency
        await asyncio.sleep(0.5)
        
        # Simulate API Response
        return {
            "current": {
                "temp": 33.2,
                "humidity": 65,
                "wind_speed": 18.5,
                "wind_deg": 45,
                "pressure": 1010,
                "uvi": 9.2,
                "visibility": 10000,
                "sunrise": 1690000000,
                "sunset": 1690040000,
                "weather": [{"description": "scattered clouds"}]
            },
            "hourly": [
                {"dt": 1690000000, "temp": 33.0, "pop": 0.2},
                {"dt": 1690003600, "temp": 32.0, "pop": 0.4},
            ],
            "daily": [
                {"dt": 1690000000, "temp": {"max": 35.0, "min": 25.0}, "summary": "Rain expected"}
            ]
        }

    def parse_current(self, raw_data: Dict[str, Any]) -> Dict[str, Any]:
        c = raw_data.get("current", {})
        return {
            "temperature": c.get("temp", 0.0),
            "humidity": float(c.get("humidity", 0)),
            "wind_speed": c.get("wind_speed", 0.0),
            "wind_direction": "NE", # Simplified for mock
            "pressure": float(c.get("pressure", 1000)),
            "rain_probability": 0.0, # Handled in hourly usually
            "uv_index": c.get("uvi", 0.0),
            "visibility": float(c.get("visibility", 10000)),
            "sunrise": datetime.fromtimestamp(c.get("sunrise", 0)).strftime("%I:%M %p"),
            "sunset": datetime.fromtimestamp(c.get("sunset", 0)).strftime("%I:%M %p"),
            "forecast_summary": c.get("weather", [{}])[0].get("description", "Clear")
        }

    def parse_hourly(self, raw_data: Dict[str, Any]) -> list:
        h = raw_data.get("hourly", [])
        return [
            {
                "timestamp": datetime.fromtimestamp(item["dt"]),
                "temperature": item["temp"],
                "rain_probability": item.get("pop", 0) * 100
            } for item in h
        ]

    def parse_daily(self, raw_data: Dict[str, Any]) -> list:
        d = raw_data.get("daily", [])
        return [
            {
                "date": datetime.fromtimestamp(item["dt"]),
                "temp_max": item["temp"]["max"],
                "temp_min": item["temp"]["min"],
                "rain_summary": item.get("summary", "")
            } for item in d
        ]
