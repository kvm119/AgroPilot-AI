from enum import Enum
import re
import logging

logger = logging.getLogger(__name__)

class Intent(str, Enum):
    CROP_RECOMMENDATION = "crop_recommendation"
    DISEASE_DETECTION = "disease_detection"
    WEATHER = "weather"
    MARKET = "market"
    GOVERNMENT_SCHEME = "government_scheme"
    MEDICINE_OCR = "medicine_ocr"
    FERTILIZER = "fertilizer"
    GENERAL = "general"
    GREETING = "greeting"
    MULTIPLE = "multiple"

class IntentClassifier:
    """
    Analyzes the raw string and metadata to map the query to one or more Intents.
    Used by the Orchestrator to prevent unnecessary API calls.
    """
    
    def classify(self, text: str, has_image: bool = False) -> Intent:
        text = text.lower()
        
        # If an image is provided without much text, assume it's for disease or medicine OCR
        if has_image:
            if "medicine" in text or "chemical" in text or "label" in text:
                return Intent.MEDICINE_OCR
            return Intent.DISEASE_DETECTION
            
        # Basic NLP / Regex routing
        greetings = ["hi", "hello", "hey", "good morning"]
        if any(g == text.strip() for g in greetings):
            return Intent.GREETING
            
        market_keywords = ["price", "sell", "market", "mandi", "demand", "trend"]
        weather_keywords = ["weather", "rain", "temperature", "forecast", "storm"]
        fertilizer_keywords = ["fertilizer", "npk", "urea", "potash", "spray"]
        disease_keywords = ["disease", "pest", "rot", "wilt", "insect", "yellow"]
        scheme_keywords = ["scheme", "pm-kisan", "subsidy", "government", "loan"]
        
        scores = {
            Intent.MARKET: sum(1 for k in market_keywords if k in text),
            Intent.WEATHER: sum(1 for k in weather_keywords if k in text),
            Intent.FERTILIZER: sum(1 for k in fertilizer_keywords if k in text),
            Intent.DISEASE_DETECTION: sum(1 for k in disease_keywords if k in text),
            Intent.GOVERNMENT_SCHEME: sum(1 for k in scheme_keywords if k in text),
        }
        
        # If multiple strong intents exist, return MULTIPLE to invoke all tools
        strong_intents = [intent for intent, score in scores.items() if score > 0]
        
        if len(strong_intents) > 1:
            return Intent.MULTIPLE
        elif len(strong_intents) == 1:
            return strong_intents[0]
            
        # Fallback
        return Intent.GENERAL
