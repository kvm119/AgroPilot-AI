import logging
from typing import List, Dict, Any
from .models.alert import Alert
from .alert_rules import AlertRulesEngine
from .alert_prioritizer import AlertPrioritizer
from .alert_repository import AlertRepository
from .notification_formatter import NotificationFormatter

logger = logging.getLogger(__name__)

class AlertEngine:
    """
    The central coordinator for proactive alerts.
    """
    def __init__(self):
        self.rules = AlertRulesEngine()
        self.prioritizer = AlertPrioritizer()
        self.repository = AlertRepository()
        self.formatter = NotificationFormatter()

    def evaluate_signals(self, weather: Dict[str, Any] = None, market: Dict[str, Any] = None, government: Dict[str, Any] = None, farm_profile: Dict[str, Any] = None) -> List[Alert]:
        farm_profile = farm_profile or {}
        raw_alerts = []
        
        # 1. Evaluate Weather Rules
        if weather:
            raw_alerts.extend(self.rules.evaluate_weather_rules(weather, farm_profile))
            
        # 2. Evaluate Market Rules
        if market:
            raw_alerts.extend(self.rules.evaluate_market_rules(market))
            
        # 3. Evaluate Government Rules
        if government:
            raw_alerts.extend(self.rules.evaluate_government_rules(government))
            
        # 4. Prioritize
        prioritized = self.prioritizer.prioritize_alerts(raw_alerts)
        
        # 5. Deduplicate and Store
        new_unique = self.repository.store_and_deduplicate(prioritized)
        
        if new_unique:
            logger.info(f"Generated {len(new_unique)} new proactive alerts.")
            
        return new_unique

    def get_active_alerts_for_dashboard(self) -> List[Dict[str, Any]]:
        active = self.repository.get_all_active_alerts()
        # Ensure they are sorted by priority
        active = self.prioritizer.prioritize_alerts(active)
        return self.formatter.format_for_flutter(active)

def get_alert_engine() -> AlertEngine:
    return AlertEngine()
