from typing import List
from .models.analytics_models import AnalyticsRecommendation, Profitability, Trend, Prediction

class RecommendationEngine:
    def generate_recommendations(
        self,
        profitability: Profitability,
        yield_trend: Trend,
        water_status: str,
        predictions: List[Prediction]
    ) -> List[AnalyticsRecommendation]:
        
        recs = []
        
        if profitability.roi_percentage < 10.0:
            recs.append(AnalyticsRecommendation(
                action="Review Input Costs",
                rationale=f"ROI is currently low ({profitability.roi_percentage}%). High input costs are reducing profit margins.",
                priority="High",
                expected_impact="Potential 5-10% increase in profit by optimizing fertilizer use."
            ))
            
        if yield_trend.direction == "DOWN":
            recs.append(AnalyticsRecommendation(
                action="Soil Health Test",
                rationale="Yield has decreased compared to the historical average.",
                priority="High",
                expected_impact="Identify nutrient deficiencies before next season."
            ))
            
        if water_status == "OVER_WATERED":
            recs.append(AnalyticsRecommendation(
                action="Delay Next Irrigation",
                rationale="Recent rainfall combined with applied irrigation exceeds crop demand.",
                priority="Medium",
                expected_impact="Save water costs and prevent root rot."
            ))
            
        return recs
