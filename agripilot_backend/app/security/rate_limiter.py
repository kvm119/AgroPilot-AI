import time
from fastapi import Request, HTTPException, status
import logging

logger = logging.getLogger(__name__)

class RateLimiter:
    """
    Simple in-memory token bucket implementation.
    In production, this should be backed by Redis using a library like fast-api-limiter.
    """
    def __init__(self):
        self.requests = {} # Dictionary mapping IP -> [timestamps]

    async def check_limit(self, request: Request, limit: int = 30, window_seconds: int = 60):
        client_ip = request.client.host if request.client else "unknown"
        now = time.time()
        
        if client_ip not in self.requests:
            self.requests[client_ip] = []
            
        # Clean old requests outside the window
        self.requests[client_ip] = [req_time for req_time in self.requests[client_ip] if now - req_time < window_seconds]
        
        if len(self.requests[client_ip]) >= limit:
            logger.warning(f"Rate limit exceeded for IP: {client_ip}")
            raise HTTPException(
                status_code=status.HTTP_429_TOO_MANY_REQUESTS,
                detail="Rate limit exceeded. Please try again later."
            )
            
        self.requests[client_ip].append(now)

rate_limiter = RateLimiter()

async def limit_copilot(request: Request):
    await rate_limiter.check_limit(request, limit=30, window_seconds=60)

async def limit_vision(request: Request):
    await rate_limiter.check_limit(request, limit=10, window_seconds=60)
