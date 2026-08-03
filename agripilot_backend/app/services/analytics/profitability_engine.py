from typing import Dict
from .models.analytics_models import Profitability

class ProfitabilityEngine:
    def calculate(self, costs: Dict[str, float], revenue: float) -> Profitability:
        # Input costs (excluding government subsidies which reduce burden)
        raw_costs = costs.get("seed_cost", 0) + costs.get("fertilizer_cost", 0) + costs.get("labor_cost", 0)
        subsidy = costs.get("government_subsidy_applied", 0)
        
        effective_costs = raw_costs - subsidy
        profit = revenue - effective_costs
        roi = (profit / effective_costs * 100) if effective_costs > 0 else 0.0
        
        return Profitability(
            revenue=revenue,
            input_costs=effective_costs,
            profit=profit,
            roi_percentage=round(roi, 2),
            government_savings=subsidy
        )
