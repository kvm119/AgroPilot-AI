from fastapi import FastAPI, Depends
from sqlalchemy.orm import Session
from .core.config import settings
from .core.database import get_db
from .monitoring.middleware import ObservabilityMiddleware
from .monitoring.exceptions import global_exception_handler
from .monitoring.health import router as health_router
from .monitoring.dashboards import router as dashboards_router
from .core.lifecycle import lifespan
from .routers import auth, users, weather, market, recommendations, notifications, copilot, vision, alerts, analytics

app = FastAPI(
    title=settings.PROJECT_NAME,
    openapi_url=f"{settings.API_V1_STR}/openapi.json",
    lifespan=lifespan
)

# Attach Monitoring Middleware
app.add_middleware(ObservabilityMiddleware)

# Attach Global Exception Handler
app.add_exception_handler(Exception, global_exception_handler)

app.include_router(auth.router, prefix=settings.API_V1_STR)
app.include_router(users.router, prefix=settings.API_V1_STR)
app.include_router(weather.router, prefix=settings.API_V1_STR)
app.include_router(market.router, prefix=settings.API_V1_STR)
app.include_router(recommendations.router, prefix=settings.API_V1_STR)
app.include_router(notifications.router, prefix=settings.API_V1_STR)
app.include_router(copilot.router, prefix=settings.API_V1_STR)
app.include_router(vision.router, prefix=settings.API_V1_STR)
app.include_router(alerts.router, prefix=settings.API_V1_STR)
app.include_router(analytics.router, prefix=settings.API_V1_STR)
app.include_router(health_router, prefix=settings.API_V1_STR)
app.include_router(dashboards_router, prefix=settings.API_V1_STR)
def health_check(db: Session = Depends(get_db)):
    """
    Health check endpoint. Also verifies database connectivity.
    """
    try:
        # Simple query to verify DB is alive
        from sqlalchemy import text
        db.execute(text("SELECT 1"))
        return {"status": "ok", "database": "connected"}
    except Exception as e:
        return {"status": "error", "detail": str(e)}

