from abc import ABC, abstractmethod
from typing import Dict, Any, List

class MarketProvider(ABC):
    """
    Abstract interface for all government and private market vendors.
    Ensures hot-swappability (e.g., Agmarknet vs ENAM).
    """
    
    @abstractmethod
    async def fetch_current_prices(self, crop: str, district: str) -> Dict[str, Any]:
        pass

    @abstractmethod
    async def fetch_historical_trends(self, crop: str, district: str, days: int = 7) -> List[Dict[str, Any]]:
        pass

    @abstractmethod
    async def fetch_nearby_markets(self, crop: str, lat: float, lon: float, radius_km: int = 50) -> List[Dict[str, Any]]:
        pass
