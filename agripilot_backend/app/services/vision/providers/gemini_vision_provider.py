import asyncio
import logging
from typing import Dict, Any
from .base_provider import VisionProvider

logger = logging.getLogger(__name__)

class GeminiVisionProvider(VisionProvider):
    """
    Mock implementation for Gemini Vision Pro.
    """
    async def analyze_image(self, image_bytes: bytes) -> Dict[str, Any]:
        logger.info("Executing Gemini Vision inference")
        await asyncio.sleep(0.8)
        return {
            "status": "success",
            "caption": "A close up of a rice leaf heavily infected with yellow rust.",
            "objects": ["rice leaf", "fungus"]
        }
