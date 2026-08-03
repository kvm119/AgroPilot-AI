from typing import List, Dict, Any
from .models.alert import Alert, AlertCategory, AlertSeverity
from datetime import datetime, timedelta
import uuid

class AlertRulesEngine:
    """
    Evaluates raw intelligence signals against deterministic logic gates.
    """
    
    def evaluate_weather_rules(self, weather_data: Dict[str, Any], farm_profile: Dict[str, Any]) -> List[Alert]:
        alerts = []
        rain_prob = weather_data.get("rain_probability", 0)
        humidity = weather_data.get("humidity", 0)
        crop = farm_profile.get("crop", "Unknown")
        
        # Rule 1: Fertilizer wash-off risk
        if rain_prob > 80:
            alerts.append(Alert(
                id=str(uuid.uuid4()),
                title="Delay Fertilizer Application",
                summary=f"{rain_prob}% chance of rain. Fertilizer will wash away.",
                severity=AlertSeverity.WARNING,
                priority="UNRATED", # Set by prioritizer later
                category=AlertCategory.FERTILIZER,
                recommended_action="Wait 24-48 hours until rain passes.",
                confidence=0.9,
                expires_at=datetime.now() + timedelta(hours=12),
                created_at=datetime.now(),
                source="WeatherRules",
                related_crop=crop
            ))
            
        # Rule 2: High Blast Disease Risk for Rice
        if humidity > 85 and crop.lower() == "rice":
            alerts.append(Alert(
                id=str(uuid.uuid4()),
                title="High Blast Disease Risk",
                summary="High humidity creates ideal conditions for Rice Blast.",
                severity=AlertSeverity.SEVERE,
                priority="UNRATED",
                category=AlertCategory.DISEASE,
                recommended_action="Monitor leaves closely. Apply preventative fungicide if spots appear.",
                confidence=0.85,
                expires_at=datetime.now() + timedelta(hours=24),
                created_at=datetime.now(),
                source="WeatherRules",
                related_crop=crop
            ))
            
        return alerts

    def evaluate_market_rules(self, market_data: Dict[str, Any]) -> List[Alert]:
        alerts = []
        # Rule 3: Price Spike
        if market_data.get("percentage_change", 0) > 10:
            alerts.append(Alert(
                id=str(uuid.uuid4()),
                title="Market Price Spike",
                summary=f"Prices for {market_data.get('commodity')} have risen rapidly.",
                severity=AlertSeverity.INFO,
                priority="UNRATED",
                category=AlertCategory.PRICE_SPIKE,
                recommended_action="Consider selling stored inventory now.",
                confidence=0.95,
                expires_at=datetime.now() + timedelta(hours=24),
                created_at=datetime.now(),
                source="MarketRules",
                related_crop=market_data.get("commodity")
            ))
        return alerts

    def evaluate_government_rules(self, scheme_data: Dict[str, Any]) -> List[Alert]:
        alerts = []
        # Rule 4: Scheme Deadline
        deadline = scheme_data.get("deadline")
        if deadline:
            days_left = (deadline - datetime.now().date()).days
            if 0 < days_left <= 7:
                alerts.append(Alert(
                    id=str(uuid.uuid4()),
                    title=f"Scheme Deadline: {scheme_data.get('name')}",
                    summary=f"Only {days_left} days left to apply.",
                    severity=AlertSeverity.WARNING,
                    priority="UNRATED",
                    category=AlertCategory.SCHEME_DEADLINE,
                    recommended_action="Upload required documents immediately.",
                    confidence=1.0,
                    expires_at=datetime.now() + timedelta(days=days_left),
                    created_at=datetime.now(),
                    source="GovernmentRules"
                ))
        return alerts
