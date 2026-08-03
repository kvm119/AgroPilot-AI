from typing import List, Dict, Any
from ...schemas.government import RawGovernmentScheme, GovernmentRecommendation
from .document_parser import DocumentParser

class RecommendationEngine:
    """
    Converts raw eligible scheme objects into structured recommendations.
    """
    def __init__(self):
        self.doc_parser = DocumentParser()

    def build_actionable_recommendations(self, schemes: List[RawGovernmentScheme], user_context: Dict[str, Any]) -> List[GovernmentRecommendation]:
        recommendations = []
        
        farm_size = user_context.get("farm_size_acres", 10.0)
        
        for s in schemes:
            reason = "You meet the general requirements."
            priority = "Medium"
            
            if s.max_land_size_acres:
                reason = f"You are eligible because your farm size ({farm_size} acres) is under the {s.max_land_size_acres} acre limit."
                priority = "High"
            elif s.state_restriction:
                reason = f"You are eligible because you farm in {s.state_restriction}."
                
            deadline_str = s.deadline.isoformat() if s.deadline else None
            docs = self.doc_parser.extract_required_documents(s)
            
            benefits_list = [b.strip() for b in s.benefits_raw_text.split('.') if b.strip()]
            
            rec = GovernmentRecommendation(
                title=s.name,
                summary=s.description,
                benefits=benefits_list,
                eligibility_reason=reason,
                required_documents=docs,
                deadline=deadline_str,
                official_link=s.url,
                priority=priority,
                confidence=0.98
            )
            recommendations.append(rec)
            
        # Sort by priority High -> Medium -> Low
        priority_map = {"High": 0, "Medium": 1, "Low": 2}
        recommendations.sort(key=lambda x: priority_map.get(x.priority, 99))
        
        return recommendations
