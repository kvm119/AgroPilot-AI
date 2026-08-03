import asyncio
import logging
from typing import Dict, Any
from .base_provider import VisionProvider

logger = logging.getLogger(__name__)

class OCRProvider(VisionProvider):
    """
    Mock implementation for Tesseract / Cloud Vision OCR.
    """
    async def analyze_image(self, image_bytes: bytes) -> Dict[str, Any]:
        logger.info("Executing OCR inference")
        await asyncio.sleep(0.5)
        return {
            "status": "success",
            "text": "FERTILIZER SUPER MAX 19-19-19\nWARNING: Keep away from children.\nExp: 12/2027"
        }
