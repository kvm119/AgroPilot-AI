from abc import ABC, abstractmethod
from typing import Dict, Any

class WeatherProvider(ABC):
    """
    Abstract interface for all third-party weather vendors.
    Ensures hot-swappability (e.g., from OpenWeather to Tomorrow.io).
    """
    
    @abstractmethod
    async def fetch_weather_data(self, lat: float, lon: float) -> Dict[str, Any]:
        """
        Fetches combined current, hourly, and daily data.
        Returns a raw dictionary that the provider knows how to map.
        """
        pass

    @abstractmethod
    def parse_current(self, raw_data: Dict[str, Any]) -> Dict[str, Any]:
        pass

    @abstractmethod
    def parse_hourly(self, raw_data: Dict[str, Any]) -> list:
        pass

    @abstractmethod
    def parse_daily(self, raw_data: Dict[str, Any]) -> list:
        pass
