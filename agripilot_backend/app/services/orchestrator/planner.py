import asyncio
import logging
from typing import Dict, Any, Set
from .tool_router import Tool

# We will mock the import of our actual API services to satisfy the planner execution
from ..weather.weather_service import get_weather_service
from ..market.market_service import get_market_service
from ..vision.vision_service import get_vision_service
from ..government.government_service import get_government_service
from ..recommendation_service import get_recommendation_service
from ..alerts.alert_engine import get_alert_engine
from ..analytics.analytics_service import get_analytics_service

logger = logging.getLogger(__name__)

class Planner:
    """
    Executes the required tools (often in parallel).
    Handles timeouts or failures gracefully without aborting the pipeline.
    """
    def __init__(self):
        self.weather_service = get_weather_service()
        self.market_service = get_market_service()
        self.vision_service = get_vision_service()
        self.government_service = get_government_service()
        self.recommendation_service = get_recommendation_service()
        self.alert_engine = get_alert_engine()
        self.analytics_service = get_analytics_service()
    
    async def execute_tools(self, required_tools: Set[Tool], image_bytes: bytes = None) -> Dict[str, Any]:
        results = {}
        tasks = []
        
        # Parallel execution wrapper
        async def safe_execute(name: str, coro) -> tuple:
            try:
                res = await coro
                return name, res
            except Exception as e:
                logger.error(f"Tool {name} failed: {e}")
                return name, None

        if Tool.WEATHER in required_tools:
            tasks.append(safe_execute(Tool.WEATHER, self.weather_service.get_agricultural_weather(16.5062, 80.6480, "Farm Location")))
            
        if Tool.MARKET in required_tools:
            tasks.append(safe_execute(Tool.MARKET, self.market_service.get_market_insights("Rice", "Guntur")))
            
        if Tool.RECOMMENDATION in required_tools:
            tasks.append(safe_execute(Tool.RECOMMENDATION, asyncio.to_thread(self.recommendation_service.get_recommendations)))
            
        if Tool.VISION in required_tools and image_bytes:
            tasks.append(safe_execute(Tool.VISION, self.vision_service.process_image(image_bytes)))
            
        if Tool.GOVERNMENT in required_tools:
            # Injecting mock user context for MVP
            user_context = {"farm_size_acres": 2.5, "state": "Andhra Pradesh", "crop": "Rice"}
            tasks.append(safe_execute(Tool.GOVERNMENT, self.government_service.fetch_eligible_schemes(user_context)))
            
        if Tool.ANALYTICS in required_tools:
            tasks.append(safe_execute(Tool.ANALYTICS, self.analytics_service.get_farm_analytics_report("farm_user_1")))
            
        # Await all network requests concurrently
        completed = await asyncio.gather(*tasks, return_exceptions=True)
        
        for item in completed:
            if isinstance(item, tuple):
                name, data = item
                if data is not None:
                    # If it's analytics, format it as text for the LLM context
                    if name == Tool.ANALYTICS:
                        results[name] = self.analytics_service.report_generator.generate_copilot_summary(data)
                    else:
                        results[name] = data
                    
        # Proactively inject signals into Alert Engine
        weather_obj = results.get(Tool.WEATHER)
        weather_temp = getattr(weather_obj, "temperature", None) if weather_obj else None
        
        self.alert_engine.evaluate_signals(
            weather={"temperature": weather_temp} if weather_temp else None,
            market=None,
            farm_profile={"crop": "Rice"}
        )
                    
        return results
