from fastapi import APIRouter, Depends, HTTPException, status
from ..schemas.recommendation import RecommendationResponse
from ..services.recommendation_service import RecommendationService, get_recommendation_service

router = APIRouter(prefix="/recommendations", tags=["Intelligence Layer"])

@router.get("", response_model=RecommendationResponse, summary="Get AI Recommendations")
def get_recommendations(service: RecommendationService = Depends(get_recommendation_service)):
    """
    Retrieves AI-driven agronomy recommendations tailored to the user's farm.
    
    This endpoint returns:
    - Actionable insights categorized by priority (high, medium, low)
    - Reasoning behind the recommendation
    - Specific suggested actions (e.g., fertilizer dosage, irrigation delay)
    - Estimated benefit to yield or cost
    
    Currently returns high-quality mock data for testing.
    """
    try:
        return service.get_recommendations()
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Failed to fetch recommendations: {str(e)}"
        )
