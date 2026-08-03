import logging
from contextlib import asynccontextmanager
from fastapi import FastAPI
from .database import engine, Base
from ..cache.redis_manager import redis_manager

logger = logging.getLogger(__name__)

@asynccontextmanager
async def lifespan(app: FastAPI):
    # Startup Events
    logger.info("Starting up AgriPilot Backend...")
    try:
        Base.metadata.create_all(bind=engine) # Setup DB (In prod, use Alembic)
        logger.info("Database tables created / verified successfully.")
    except Exception as e:
        logger.warning(f"Database connection warning during startup: {e}")
        
    try:
        await redis_manager.connect()
        logger.info("Redis connected successfully.")
    except Exception as e:
        logger.warning(f"Redis connection warning during startup: {e}")
    
    yield
    
    # Shutdown Events (Graceful Shutdown)
    logger.info("Shutting down AgriPilot Backend...")
    try:
        await redis_manager.disconnect()
    except Exception:
        pass
    engine.dispose()
