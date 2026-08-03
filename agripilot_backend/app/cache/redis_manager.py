import json
import logging
from typing import Any, Optional
import redis.asyncio as redis
from ..core.config import settings

logger = logging.getLogger(__name__)

class RedisManager:
    """
    Centralized Redis caching layer for AgriPilot.
    """
    def __init__(self):
        self.redis_client = None
        
    async def connect(self):
        self.redis_client = redis.from_url(settings.REDIS_URL, decode_responses=True)
        logger.info("Connected to Redis cache.")
        
    async def disconnect(self):
        if self.redis_client:
            await self.redis_client.close()
            logger.info("Disconnected from Redis cache.")
            
    async def get(self, key: str) -> Optional[Any]:
        if not self.redis_client:
            return None
        data = await self.redis_client.get(key)
        return json.loads(data) if data else None
        
    async def set(self, key: str, value: Any, ttl_seconds: int = 3600):
        if not self.redis_client:
            return
        await self.redis_client.setex(key, ttl_seconds, json.dumps(value))
        
redis_manager = RedisManager()
