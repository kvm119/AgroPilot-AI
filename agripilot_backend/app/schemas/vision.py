from pydantic import BaseModel, Field
from typing import List, Optional

class BoundingBox(BaseModel):
    x_min: float
    y_min: float
    x_max: float
    y_max: float

class DetectedObject(BaseModel):
    label: str
    confidence: float
    bbox: Optional[BoundingBox] = None

class OCRResult(BaseModel):
    raw_text: str
    product_name: Optional[str] = None
    npk_ratio: Optional[str] = None
    safety_warnings: List[str] = []
    expiry_date: Optional[str] = None

class DiseasePrediction(BaseModel):
    disease: str = Field(..., example="Rice Leaf Blast (Magnaporthe oryzae)")
    confidence: float = Field(..., example=0.92)
    severity: str = Field(..., example="Medium")
    affected_area: str = Field(default="Foliage / Upper Leaves", example="Foliage / Upper Leaves")
    possible_causes: List[str] = Field(default_factory=list, example=["High humidity (>85%)", "Excessive nitrogen fertilizer"])
    immediate_actions: List[str] = Field(default_factory=list, example=["Drain standing field water", "Apply recommended fungicide"])
    recommended_medicine: str = Field(default="Tricyclazole 75% WP", example="Tricyclazole 75% WP")
    dosage: str = Field(default="0.6g per Liter water", example="0.6g per Liter water")
    precautions: List[str] = Field(default_factory=list, example=["Wear gloves during spray", "Do not spray before rain"])
    expected_recovery_time: str = Field(default="7 - 10 Days", example="7 - 10 Days")
    when_to_contact_expert: str = Field(default="If lesion spreading exceeds 30% after 5 days", example="If lesion spreading exceeds 30% after 5 days")
    urgency: str = Field(..., example="Critical")
    treatment: str = Field(..., example="Apply Tricyclazole 75% WP @ 0.6g/L.")

class VisionMetadata(BaseModel):
    image_hash: str
    cached: bool
    processed_providers: List[str] = []
    width: Optional[int] = 1024
    height: Optional[int] = 1024
    format: Optional[str] = "JPEG"
    latency_ms: Optional[int] = 350

class ImageInsight(BaseModel):
    disease_prediction: Optional[DiseasePrediction] = None
    ocr_result: Optional[OCRResult] = None
    detected_objects: List[DetectedObject] = []
    caption: str = Field(..., example="A rice leaf showing severe blast symptoms.")
    metadata: VisionMetadata
    is_fallback: bool = False
