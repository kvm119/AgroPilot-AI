import logging
import asyncio
import hashlib
from typing import Dict, Any, List
from datetime import datetime, timedelta

from ..services.vision.providers.yolo_provider import YOLOProvider
from ..services.vision.providers.ocr_provider import OCRProvider
from ..services.vision.providers.gemini_vision_provider import GeminiVisionProvider

logger = logging.getLogger(__name__)

class VisionRepository:
    """
    Executes multiple vision models concurrently.
    Uses SHA-256 caching to prevent redundant processing of the same image.
    """
    def __init__(self):
        self.yolo = YOLOProvider()
        self.ocr = OCRProvider()
        self.gemini = GeminiVisionProvider()
        
        # In-memory cache mapping SHA256 -> Inference Results
        self._cache: Dict[str, Dict[str, Any]] = {}
        self.CACHE_TTL_HOURS = 24

    def _hash_image(self, image_bytes: bytes) -> str:
        return hashlib.sha256(image_bytes).hexdigest()

    async def analyze_image(self, image_bytes: bytes) -> Dict[str, Any]:
        image_hash = self._hash_image(image_bytes)
        now = datetime.now()
        
        cached = self._cache.get(image_hash)
        if cached and cached["expires_at"] > now:
            logger.info(f"Vision Cache HIT for {image_hash}")
            result = cached["data"]
            result["metadata"]["cached"] = True
            return result
            
        logger.info(f"Vision Cache MISS for {image_hash}. Executing parallel inference...")
        
        # Execute models concurrently
        # return_exceptions=True prevents one model failure from crashing the pipeline
        results = await asyncio.gather(
            self.yolo.analyze_image(image_bytes),
            self.ocr.analyze_image(image_bytes),
            self.gemini.analyze_image(image_bytes),
            return_exceptions=True
        )
        
        yolo_res = results[0] if not isinstance(results[0], Exception) else {}
        ocr_res = results[1] if not isinstance(results[1], Exception) else {}
        gemini_res = results[2] if not isinstance(results[2], Exception) else {}
        
        processed = []
        if yolo_res: processed.append("yolo")
        if ocr_res: processed.append("ocr")
        if gemini_res: processed.append("gemini")
        
        final_data = {
            "yolo": yolo_res,
            "ocr": ocr_res,
            "gemini": gemini_res,
            "metadata": {
                "image_hash": image_hash,
                "cached": False,
                "processed_providers": processed
            }
        }
        
        self._cache[image_hash] = {
            "data": final_data,
            "expires_at": now + timedelta(hours=self.CACHE_TTL_HOURS)
        }
        
        return final_data
