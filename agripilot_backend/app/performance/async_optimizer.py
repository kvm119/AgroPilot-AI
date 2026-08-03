import asyncio
from typing import Coroutine, List, Any
import logging

logger = logging.getLogger(__name__)

class AsyncOptimizer:
    """
    Ensures that I/O bound tasks never block the event loop sequentially.
    """
    
    @staticmethod
    async def gather_safe(*tasks: Coroutine) -> List[Any]:
        """
        Executes a batch of async tasks concurrently while safely trapping exceptions
        to prevent a single failure from failing the entire batch (e.g. failing to fetch Weather shouldn't crash Market fetch).
        """
        logger.debug(f"Optimizing {len(tasks)} parallel I/O calls via asyncio.gather")
        return await asyncio.gather(*tasks, return_exceptions=True)
