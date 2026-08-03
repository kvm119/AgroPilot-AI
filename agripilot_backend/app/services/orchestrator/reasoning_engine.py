from typing import Dict, Any, List
from .tool_router import Tool
from ...schemas.weather import WeatherResponse
from ...schemas.market import MarketResponse
from ...schemas.recommendation import RecommendationResponse

class ReasoningEngine:
    """
    Merges disparate data types into a logical graph so the LLM 
    doesn't have to deduce the rules from scratch.
    """
    
    def combine(self, tool_results: Dict[str, Any], user_context: Dict[str, Any]) -> str:
        lines = []
        lines.append("FARM CONTEXT:")
        lines.append(str(user_context))
        
        lines.append("\nREASONING GRAPH:")
        
        # Analyze Weather
        weather: WeatherResponse = tool_results.get(Tool.WEATHER)
        if weather:
            lines.append(f"- Weather is {weather.temperature}C with {weather.rain_probability}% rain chance.")
            if weather.rain_probability > 50:
                lines.append("-> INFERENCE: Delay any chemical spraying or fertilization.")
                
        # Analyze Market
        market: MarketResponse = tool_results.get(Tool.MARKET)
        if market:
            # Assuming primary crop is Rice
            crop = user_context.get("farm_details", {}).get("primary_crop", "")
            for item in market.items:
                if crop.lower() in item.crop_name.lower():
                    lines.append(f"- Market price for {crop} is {item.current_price} ({item.weekly_trend})")
                    if item.weekly_trend == "up":
                        lines.append("-> INFERENCE: Holding crop may yield higher profits.")
                    break
                    
        # Analyze Vision (Mock)
        vision = tool_results.get(Tool.VISION)
        if vision:
            lines.append(f"- Vision AI detected {vision['disease']} with {vision['confidence']} confidence.")
            lines.append("-> INFERENCE: Immediate fungicide intervention required.")
            
        return "\n".join(lines)
