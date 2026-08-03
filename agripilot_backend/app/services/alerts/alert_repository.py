from typing import List, Dict, Any
import hashlib
import logging
from datetime import datetime
from .models.alert import Alert

logger = logging.getLogger(__name__)

class AlertRepository:
    """
    Deduplicates and stores active alerts.
    """
    def __init__(self):
        # In-memory alert store keyed by semantic hash
        self._active_alerts: Dict[str, Alert] = {}

    def _hash_alert(self, alert: Alert) -> str:
        # A semantic hash based on title, category, and crop
        # This prevents 5 "Rain" alerts from triggering 5 notifications.
        seed = f"{alert.title}_{alert.category}_{alert.related_crop}"
        return hashlib.md5(seed.encode()).hexdigest()

    def store_and_deduplicate(self, alerts: List[Alert]) -> List[Alert]:
        unique_alerts = []
        now = datetime.now()
        
        # Clean expired alerts first
        expired_keys = [k for k, v in self._active_alerts.items() if v.expires_at < now]
        for k in expired_keys:
            del self._active_alerts[k]

        for alert in alerts:
            ahash = self._hash_alert(alert)
            if ahash not in self._active_alerts:
                logger.info(f"New Unique Alert Registered: {alert.title}")
                self._active_alerts[ahash] = alert
                unique_alerts.append(alert)
            else:
                logger.debug(f"Alert Suppressed (Duplicate): {alert.title}")
                
        return unique_alerts

    def get_all_active_alerts(self) -> List[Alert]:
        now = datetime.now()
        return [a for a in self._active_alerts.values() if a.expires_at > now]
