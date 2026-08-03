import logging
import asyncio
from typing import Dict, Any, List
from datetime import datetime, timedelta
from .base_provider import MarketProvider

logger = logging.getLogger(__name__)

class AgmarknetProvider(MarketProvider):
    """
    Implementation for India's Agmarknet Government portal.
    Currently uses mock simulation of the network request for MVP testing.
    """
    async def fetch_current_prices(self, crop: str, district: str) -> Dict[str, Any]:
        logger.info(f"Fetching Agmarknet API for {crop} in {district}")
        await asyncio.sleep(0.4) # Simulate latency
        
        # Mock Response
        return {
            "commodity": crop,
            "district": district,
            "state": "Andhra Pradesh",
            "market": f"{district} APMC",
            "min_price": 2300.0,
            "max_price": 2600.0,
            "modal_price": 2450.0,
            "arrival_qty": 120.5,
            "date": datetime.now().isoformat()
        }

    async def fetch_historical_trends(self, crop: str, district: str, days: int = 7) -> List[Dict[str, Any]]:
        await asyncio.sleep(0.2)
        history = []
        base_price = 2400.0
        # Mock a rising trend
        for i in range(days, 0, -1):
            date = datetime.now() - timedelta(days=i)
            history.append({
                "date": date.isoformat(),
                "modal_price": base_price + (i * -10.0), # price was lower in the past
                "arrival_qty": 100.0
            })
        return history

    async def fetch_nearby_markets(self, crop: str, lat: float, lon: float, radius_km: int = 50) -> List[Dict[str, Any]]:
        await asyncio.sleep(0.2)
        return [
            {
                "market": "Vijayawada Central",
                "district": "Krishna",
                "modal_price": 2550.0 # higher price nearby
            }
        ]
