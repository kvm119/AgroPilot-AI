from abc import ABC, abstractmethod
from typing import Dict, Any

class VisionProvider(ABC):
    """
    Abstract interface for all Vision Models (YOLO, OCR, LLMs).
    """
    
    @abstractmethod
    async def analyze_image(self, image_bytes: bytes) -> Dict[str, Any]:
        """
        Executes model inference and returns provider-specific JSON output.
        """
        pass
