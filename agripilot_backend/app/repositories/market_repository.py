import logging
from typing import Dict, Any, List
from datetime import datetime, timedelta

from ..services.market.providers.base_provider import MarketProvider
from ..services.market.providers.agmarknet_provider import AgmarknetProvider

logger = logging.getLogger(__name__)

class MarketRepository:
    """
    Handles fetching from providers and intelligent caching.
    Implements Stale-While-Revalidate pattern.
    """
    def __init__(self, provider: MarketProvider = None):
        self.provider = provider or AgmarknetProvider()
        # In-memory cache keyed by (crop, district)
        self._current_cache: Dict[tuple, Dict[str, Any]] = {}
        self._history_cache: Dict[tuple, Dict[str, Any]] = {}
        
        self.CURRENT_TTL_MINUTES = 15
        self.HISTORY_TTL_HOURS = 6

    async def get_market_prices(self, crop: str, district: str) -> Dict[str, Any]:
        cache_key = (crop, district)
        now = datetime.now()
        
        cached = self._current_cache.get(cache_key)
        
        if cached and cached["expires_at"] > now:
            logger.info(f"Market Cache HIT for {crop}, {district}")
            return cached["data"]
            
        try:
            logger.info(f"Market Cache MISS for {crop}, {district}. Fetching...")
            data = await self.provider.fetch_current_prices(crop, district)
            
            self._current_cache[cache_key] = {
                "data": data,
                "expires_at": now + timedelta(minutes=self.CURRENT_TTL_MINUTES)
            }
            return data
            
        except Exception as e:
            logger.error(f"Market API Failed: {str(e)}")
            if cached:
                return cached["data"]
            return self._get_ultimate_fallback(crop, district)

    async def get_historical_trends(self, crop: str, district: str) -> List[Dict[str, Any]]:
        cache_key = (crop, district)
        now = datetime.now()
        
        cached = self._history_cache.get(cache_key)
        if cached and cached["expires_at"] > now:
            return cached["data"]
            
        try:
            data = await self.provider.fetch_historical_trends(crop, district)
            self._history_cache[cache_key] = {
                "data": data,
                "expires_at": now + timedelta(hours=self.HISTORY_TTL_HOURS)
            }
            return data
        except Exception:
            return cached["data"] if cached else []

    async def get_nearby_markets(self, crop: str, lat: float, lon: float) -> List[Dict[str, Any]]:
        # Not heavily cached for MVP
        try:
            return await self.provider.fetch_nearby_markets(crop, lat, lon)
        except Exception:
            return []

    def _get_ultimate_fallback(self, crop: str, district: str) -> Dict[str, Any]:
        return {
            "commodity": crop,
            "district": district,
            "state": "Unknown",
            "market": "Unknown",
            "min_price": 0.0,
            "max_price": 0.0,
            "modal_price": 0.0,
            "arrival_qty": 0.0,
            "is_fallback": True
        }
