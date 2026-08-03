from typing import Dict, Any
from datetime import datetime, timedelta
from .models.analytics_models import Prediction

class PredictionEngine:
    def predict_harvest_date(self, lifecycle: Dict[str, Any]) -> Prediction:
        planting_str = lifecycle.get("planting_date")
        dtm = lifecycle.get("seed_variety_days_to_maturity", 100)
        
        try:
            planting_date = datetime.strptime(planting_str, "%Y-%m-%d").date()
            harvest_date = planting_date + timedelta(days=dtm)
            
            return Prediction(
                target="Estimated Harvest Date",
                predicted_value=harvest_date.isoformat(),
                confidence=0.85,
                rationale=f"Calculated deterministically: {dtm} days from planting date {planting_str}."
            )
        except Exception:
            return Prediction(
                target="Estimated Harvest Date",
                predicted_value="Unknown",
                confidence=0.0,
                rationale="Invalid planting date format."
            )
