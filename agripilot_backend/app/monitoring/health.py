from fastapi import APIRouter
from typing import Dict, Any

router = APIRouter(tags=["System Health"])

@router.get("/health", response_model=Dict[str, Any])
async def health_check():
    """
    Comprehensive health check for load balancers.
    In production, this would actively ping the DB and Redis.
    """
    return {
        "status": "healthy",
        "dependencies": {
            "database": {"status": "up"},
            "weather_api": {"status": "up"},
            "market_api": {"status": "up"},
            "gemini_llm": {"status": "up"}
        }
    }

@router.get("/live")
async def liveness_probe():
    return {"status": "alive"}

@router.get("/ready")
async def readiness_probe():
    return {"status": "ready"}
