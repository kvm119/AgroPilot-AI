from typing import Dict, Any

class ConfidenceEngine:
    """
    Grades the final output based on API data freshness and availability.
    """
    
    def calculate_confidence(self, tool_results: Dict[str, Any], llm_confidence: float = 0.85) -> float:
        # Base confidence from LLM
        confidence = llm_confidence
        
        # Penalize if critical tools failed
        if not tool_results:
            confidence -= 0.4
            
        # Example: Mock penalizing if market data wasn't found
        # In a real app, we check timestamps of the data payload.
        
        # Bound between 0 and 1
        return max(0.0, min(1.0, confidence))
