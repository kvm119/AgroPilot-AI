from fastapi import APIRouter, Depends, HTTPException, status, Query
from ..schemas.weather import WeatherResponse
from ..services.weather.weather_service import WeatherService, get_weather_service

router = APIRouter(prefix="/weather", tags=["Weather Intelligence"])

@router.get("", response_model=WeatherResponse, summary="Get real-time agricultural weather intelligence")
async def get_weather(
    lat: float = Query(16.5062, description="Latitude"),
    lon: float = Query(80.6480, description="Longitude"),
    service: WeatherService = Depends(get_weather_service)
):
    try:
        # Resolve coordinates to a logical location name using a geocoder in production.
        return await service.get_agricultural_weather(lat, lon, "Vijayawada, Andhra Pradesh")
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Weather Intelligence Engine failed: {str(e)}"
        )
