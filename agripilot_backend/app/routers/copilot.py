from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session
from ..core.database import get_db
from ..schemas.copilot import ChatRequest, ChatResponse
from ..services.orchestrator.orchestrator_service import OrchestratorService, get_orchestrator_service

router = APIRouter(prefix="/copilot", tags=["AI Copilot Engine"])

@router.post("/chat", response_model=ChatResponse, summary="Send message to AI Copilot")
async def chat_with_copilot(
    request: ChatRequest,
    db: Session = Depends(get_db)
):
    service = get_orchestrator_service(db)
    """
    Core AI orchestration endpoint.
    
    Pipeline:
    1. Loads Farmer Profile & Farm Details
    2. Loads Weather, Market, and active Recommendations
    3. Fetches Conversation History
    4. Builds an optimized, modular prompt
    5. Calls the LLM (Gemini) securely
    6. Returns structured response with safety fallbacks
    """
    try:
        response = await service.handle_chat(request)
        return response
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Copilot engine failed: {str(e)}"
        )
