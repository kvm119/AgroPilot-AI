from typing import List, Dict, Any

class RecommendationRanker:
    """
    Sorts actionable steps based on urgency and farm impact.
    """
    
    def rank(self, recommendations: List[Dict[str, Any]]) -> List[Dict[str, Any]]:
        # Sort by priority (high > medium > low)
        priority_map = {"high": 3, "medium": 2, "low": 1}
        
        return sorted(
            recommendations, 
            key=lambda x: priority_map.get(x.get("priority", "low"), 0), 
            reverse=True
        )
