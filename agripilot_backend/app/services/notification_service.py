from datetime import datetime, timezone, timedelta
from ..schemas.notification import NotificationResponse, NotificationItem

class NotificationService:
    def get_notifications(self) -> NotificationResponse:
        """
        Mock implementation for Notification Service.
        Will eventually be driven by event pipelines and push notification workers.
        """
        now = datetime.now(timezone.utc)
        items = [
            NotificationItem(
                id="notif_1",
                title="Heavy Rain Alert",
                message="Heavy rainfall expected in your area tomorrow evening. Secure harvested crops.",
                severity="warning",
                timestamp=now - timedelta(minutes=45),
                is_read=False,
                action_required=True
            ),
            NotificationItem(
                id="notif_2",
                title="Market Price Spike",
                message="Cotton prices in Guntur mandi jumped by 3% in the last 2 hours.",
                severity="info",
                timestamp=now - timedelta(hours=3),
                is_read=False,
                action_required=False
            ),
            NotificationItem(
                id="notif_3",
                title="PM-Kisan Scheme Deadline",
                message="e-KYC verification deadline is approaching. Complete it via the portal.",
                severity="critical",
                timestamp=now - timedelta(days=1),
                is_read=True,
                action_required=True
            )
        ]
        
        unread_count = sum(1 for x in items if not x.is_read)
        
        return NotificationResponse(
            unread_count=unread_count,
            notifications=items
        )

# Dependency injection helper
def get_notification_service() -> NotificationService:
    return NotificationService()
