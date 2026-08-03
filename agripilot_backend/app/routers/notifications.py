from fastapi import APIRouter, Depends, HTTPException, status
from ..schemas.notification import NotificationResponse
from ..services.notification_service import NotificationService, get_notification_service

router = APIRouter(prefix="/notifications", tags=["Intelligence Layer"])

@router.get("", response_model=NotificationResponse, summary="Get Notifications")
def get_notifications(service: NotificationService = Depends(get_notification_service)):
    """
    Retrieves the user's recent notifications and alerts.
    
    This endpoint returns:
    - Total unread notification count
    - A list of notifications sorted by timestamp
    - Severity indicators (critical, warning, info)
    
    Currently returns high-quality mock data for testing.
    """
    try:
        return service.get_notifications()
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Failed to fetch notifications: {str(e)}"
        )
