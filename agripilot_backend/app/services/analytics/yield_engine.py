from typing import List, Dict, Any

class YieldEngine:
    def calculate_yield_metrics(self, yield_history: List[Dict[str, Any]]) -> Dict[str, float]:
        if not yield_history:
            return {"average_yield": 0.0, "current_yield": 0.0}
            
        total = sum(y["yield_tpa"] for y in yield_history)
        avg = total / len(yield_history)
        current = yield_history[-1]["yield_tpa"]
        
        return {
            "average_yield": round(avg, 2),
            "current_yield": current
        }
