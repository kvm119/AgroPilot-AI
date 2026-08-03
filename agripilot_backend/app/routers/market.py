from fastapi import APIRouter, Depends, HTTPException, status, Query
from typing import Optional
from ..schemas.market import MarketResponse, MarketAnalysisResponse
from ..services.market.market_service import MarketService, get_market_service

router = APIRouter(prefix="/market", tags=["Market Intelligence Engine"])

@router.get("", response_model=MarketResponse, summary="Get Live Market Intelligence Summary")
async def get_market_prices(
    crop: str = Query("Rice", description="Crop name"),
    district: str = Query("Guntur", description="District name"),
    lat: float = Query(16.3067, description="Latitude"),
    lon: float = Query(80.4365, description="Longitude"),
    service: MarketService = Depends(get_market_service)
):
    """
    Retrieves current market prices for relevant crops.
    """
    try:
        return await service.get_market_insights(crop, district, lat, lon)
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Failed to fetch market data: {str(e)}"
        )

@router.get("/analysis", response_model=MarketAnalysisResponse, summary="Get Indian Agricultural Market Analysis")
async def get_market_analysis(
    category: Optional[str] = Query(None, description="Category filter (Fruits, Vegetables, Cereals, Pulses, Oil Seeds, Spices, Commercial)"),
    state: Optional[str] = Query(None, description="State filter (e.g., Andhra Pradesh, Maharashtra, Karnataka)"),
    search: Optional[str] = Query(None, description="Search query for commodity or mandi"),
    service: MarketService = Depends(get_market_service)
):
    """
    Returns rich Indian Agricultural Market Analysis intelligence with price trends, moving averages,
    historical chart points (1D, 1W, 1M, 1Y), nearby market comparisons, and AI trade recommendations.
    """
    try:
        return await service.get_market_analysis(category=category, state=state, search=search)
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Failed to fetch market analysis: {str(e)}"
        )
