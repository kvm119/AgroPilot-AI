from typing import List
from .models.alert import Alert, AlertPriority, AlertCategory, AlertSeverity

class AlertPrioritizer:
    """
    Ranks unrated alerts into CRITICAL, HIGH, MEDIUM, LOW categories.
    """
    
    def prioritize_alerts(self, alerts: List[Alert]) -> List[Alert]:
        for alert in alerts:
            score = 0
            
            # Severity weight
            if alert.severity == AlertSeverity.SEVERE:
                score += 50
            elif alert.severity == AlertSeverity.WARNING:
                score += 30
            elif alert.severity == AlertSeverity.INFO:
                score += 10
                
            # Category weight
            if alert.category in [AlertCategory.DISEASE, AlertCategory.WEATHER, AlertCategory.PEST]:
                score += 30 # Crop failure risks
            elif alert.category in [AlertCategory.MARKET, AlertCategory.PRICE_SPIKE, AlertCategory.PRICE_DROP]:
                score += 20 # Economic risks
            elif alert.category == AlertCategory.SCHEME_DEADLINE:
                score += 40 # Hard deadlines
                
            # Assign priority
            if score >= 70:
                alert.priority = AlertPriority.CRITICAL
            elif score >= 50:
                alert.priority = AlertPriority.HIGH
            elif score >= 30:
                alert.priority = AlertPriority.MEDIUM
            else:
                alert.priority = AlertPriority.LOW
                
        # Sort so CRITICAL is first
        priority_order = {AlertPriority.CRITICAL: 0, AlertPriority.HIGH: 1, AlertPriority.MEDIUM: 2, AlertPriority.LOW: 3}
        alerts.sort(key=lambda a: priority_order.get(a.priority, 4))
        
        return alerts
