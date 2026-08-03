from typing import List, Dict, Any
from .models.analytics_models import Trend

class TrendEngine:
    def calculate_yield_trend(self, yield_metrics: Dict[str, float]) -> Trend:
        avg = yield_metrics["average_yield"]
        current = yield_metrics["current_yield"]
        
        if avg == 0:
            return Trend(metric_name="Yield", direction="STABLE", percentage_change=0, historical_average=0, current_value=current)
            
        diff = current - avg
        pct = (diff / avg) * 100
        
        direction = "STABLE"
        if pct > 5:
            direction = "UP"
        elif pct < -5:
            direction = "DOWN"
            
        return Trend(
            metric_name="Yield (Tons/Acre)",
            direction=direction,
            percentage_change=round(pct, 2),
            historical_average=avg,
            current_value=current
        )
