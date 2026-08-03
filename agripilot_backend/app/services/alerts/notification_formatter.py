from typing import List, Dict, Any
from .models.alert import Alert

class NotificationFormatter:
    """
    Formats internal Alert objects into payloads for Flutter, Push, and SMS.
    """
    
    def format_for_flutter(self, alerts: List[Alert]) -> List[Dict[str, Any]]:
        payload = []
        for a in alerts:
            payload.append({
                "id": a.id,
                "title": a.title,
                "summary": a.summary,
                "severity": a.severity.value,
                "priority": a.priority.value,
                "category": a.category.value,
                "recommended_action": a.recommended_action,
                "source": a.source,
                "is_active": True,
                "timestamp": a.created_at.isoformat()
            })
        return payload

    def format_for_sms(self, alert: Alert) -> str:
        return f"AgriPilot Alert: {alert.title}. {alert.recommended_action}"
