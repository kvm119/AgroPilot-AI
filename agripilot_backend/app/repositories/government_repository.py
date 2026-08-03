import logging
import asyncio
from typing import List, Dict, Any
from datetime import datetime, timedelta

from ..services.government.providers.pmkisan_provider import PMKisanProvider
from ..services.government.providers.state_scheme_provider import StateSchemeProvider
from ..services.government.providers.subsidy_provider import SubsidyProvider
from ..schemas.government import RawGovernmentScheme

logger = logging.getLogger(__name__)

class GovernmentRepository:
    """
    Fetches raw schemes from all providers and merges them.
    Implements 24-hour Stale-While-Revalidate caching to survive API failures.
    """
    def __init__(self):
        self.providers = [
            PMKisanProvider(),
            StateSchemeProvider(),
            SubsidyProvider()
        ]
        
        # In-memory cache
        self._cache: Dict[str, Dict[str, Any]] = {}
        self.CACHE_TTL_HOURS = 24

    async def get_all_schemes(self) -> List[RawGovernmentScheme]:
        return await self._fetch_with_cache("schemes")

    async def get_all_subsidies(self) -> List[RawGovernmentScheme]:
        return await self._fetch_with_cache("subsidies")

    async def get_all_loans(self) -> List[RawGovernmentScheme]:
        return await self._fetch_with_cache("loans")

    async def _fetch_with_cache(self, fetch_type: str) -> List[RawGovernmentScheme]:
        now = datetime.now()
        cached = self._cache.get(fetch_type)
        
        if cached and cached["expires_at"] > now:
            logger.info(f"Government Cache HIT for {fetch_type}")
            return cached["data"]
            
        logger.info(f"Government Cache MISS for {fetch_type}. Fetching from providers...")
        
        tasks = []
        for p in self.providers:
            if fetch_type == "schemes":
                tasks.append(p.fetch_schemes())
            elif fetch_type == "subsidies":
                tasks.append(p.fetch_subsidies())
            elif fetch_type == "loans":
                tasks.append(p.fetch_loans_and_insurance())

        results = await asyncio.gather(*tasks, return_exceptions=True)
        
        merged_data: List[RawGovernmentScheme] = []
        for res in results:
            if not isinstance(res, Exception):
                merged_data.extend(res)
            else:
                logger.error(f"Provider failed to fetch {fetch_type}: {res}")
                
        # Only cache if we got some data
        if merged_data:
            self._cache[fetch_type] = {
                "data": merged_data,
                "expires_at": now + timedelta(hours=self.CACHE_TTL_HOURS)
            }
            return merged_data
        elif cached:
            # Fallback to stale cache if all failed
            return cached["data"]
            
        return []
