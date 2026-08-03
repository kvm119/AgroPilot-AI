from fastapi import APIRouter, Depends, HTTPException, status
from typing import Dict, Any
from ..services.analytics.analytics_service import AnalyticsService, get_analytics_service

router = APIRouter(prefix="/analytics", tags=["Analytics"])


@router.get("/summary", response_model=Dict[str, Any], summary="Get Farm Analytics Summary")
async def get_analytics_summary(
    season: str = "current",
    service: AnalyticsService = Depends(get_analytics_service)
):
    """
    Retrieves a general analytics summary for the authenticated user's farm.
    Used by Flutter Dashboard analytics tab.
    """
    try:
        report = await service.get_farm_analytics_report("default_farm", season)
        return service.report_generator.generate_dashboard_json(report)
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Failed to fetch analytics summary: {str(e)}"
        )


@router.get("/{farm_id}/dashboard", response_model=Dict[str, Any], summary="Get Farm Analytics Dashboard")
async def get_dashboard_metrics(
    farm_id: str,
    season: str = "current",
    service: AnalyticsService = Depends(get_analytics_service)
):
    """
    Retrieves the pre-calculated analytics metrics for the Flutter Dashboard.
    """
    try:
        report = await service.get_farm_analytics_report(farm_id, season)
        return service.report_generator.generate_dashboard_json(report)
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Failed to fetch analytics metrics: {str(e)}"
        )
