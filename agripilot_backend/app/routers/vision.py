from typing import Optional
from fastapi import APIRouter, Depends, HTTPException, status, UploadFile, File, Form
from ..schemas.vision import ImageInsight
from ..services.vision.vision_service import VisionService, get_vision_service

router = APIRouter(prefix="/vision", tags=["Vision Intelligence"])

@router.post("", response_model=ImageInsight, summary="Analyze an agricultural image")
@router.post("/analyze", response_model=ImageInsight, summary="Analyze an agricultural image (alias)")
async def analyze_image(
    file: UploadFile = File(...),
    user_observation: Optional[str] = Form(None),
    service: VisionService = Depends(get_vision_service)
):
    """
    Multimodal Vision Intelligence endpoint.
    Accepts crop image upload AND optional user observation context text (e.g., 'Brown spots on leaf').
    """
    try:
        image_bytes = await file.read()
        return await service.process_image(image_bytes, user_observation=user_observation)
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Vision Intelligence Engine failed: {str(e)}"
        )
