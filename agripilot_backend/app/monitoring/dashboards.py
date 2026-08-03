from fastapi import APIRouter
from typing import Dict, Any
from .metrics import global_metrics

router = APIRouter(prefix="/monitoring", tags=["Monitoring Dashboards"])

@router.get("/dashboard/system")
async def system_dashboard() -> Dict[str, Any]:
    """
    Returns system-wide aggregated metrics (Traffic, Latency, Errors).
    """
    return global_metrics.get_summary()

@router.get("/dashboard/ai")
async def ai_dashboard() -> Dict[str, Any]:
    """
    Mock AI aggregated dashboard for the Flutter Admin panel.
    """
    return {
        "questions_today": 1420,
        "images_processed": 315,
        "average_confidence": 0.89,
        "average_response_time_ms": 2150,
        "top_intents": ["disease_detection", "market_price", "weather_forecast"],
        "most_common_crops": ["Rice", "Wheat", "Cotton"]
    }
