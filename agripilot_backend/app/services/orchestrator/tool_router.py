from typing import List, Set
from .intent_classifier import Intent
import logging

logger = logging.getLogger(__name__)

class Tool(str):
    WEATHER = "weather_api"
    MARKET = "market_api"
    VISION = "vision_api"
    OCR = "ocr_api"
    GOVERNMENT = "government_api"
    RECOMMENDATION = "recommendation_api"
    CONTEXT = "farm_context"
    ANALYTICS = "analytics_api"

class ToolRouter:
    """
    Determines WHICH external APIs are strictly necessary based on the classified intent.
    This minimizes latency by pruning the dependency graph.
    """
    
    def get_required_tools(self, intent: Intent) -> Set[Tool]:
        tools: Set[Tool] = {Tool.CONTEXT} # Farm context is always required
        
        if intent == Intent.WEATHER:
            tools.add(Tool.WEATHER)
        elif intent == Intent.MARKET:
            tools.add(Tool.MARKET)
        elif intent == Intent.DISEASE_DETECTION:
            tools.add(Tool.VISION)
            tools.add(Tool.WEATHER) # Weather impacts disease spread
        elif intent == Intent.MEDICINE_OCR:
            tools.add(Tool.OCR)
        elif intent == Intent.GOVERNMENT_SCHEME:
            tools.add(Tool.GOVERNMENT)
        elif intent == Intent.FERTILIZER:
            tools.add(Tool.WEATHER)
            tools.add(Tool.RECOMMENDATION)
        elif intent == Intent.MULTIPLE:
            tools.update([Tool.WEATHER, Tool.MARKET, Tool.RECOMMENDATION])
        elif intent == Intent.GENERAL:
            tools.add(Tool.RECOMMENDATION)
            
        logger.info(f"Routed Tools for {intent}: {tools}")
        return tools
