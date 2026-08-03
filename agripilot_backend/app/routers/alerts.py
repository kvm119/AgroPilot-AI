from fastapi import APIRouter, Depends, HTTPException, status
from typing import List, Dict, Any
from ..services.alerts.alert_engine import AlertEngine, get_alert_engine

router = APIRouter(prefix="/alerts", tags=["Notifications"])

@router.get("", response_model=List[Dict[str, Any]], summary="Get active alerts for dashboard")
async def get_alerts(engine: AlertEngine = Depends(get_alert_engine)):
    """
    Retrieves prioritized active alerts for the Flutter dashboard.
    """
    try:
        return engine.get_active_alerts_for_dashboard()
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Failed to fetch alerts: {str(e)}"
        )
