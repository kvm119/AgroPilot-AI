from celery import Celery
from celery.schedules import crontab
from ..core.config import settings

celery_app = Celery(
    "agripilot_workers",
    broker=settings.CELERY_BROKER_URL,
    include=["app.workers.background_tasks"]
)

celery_app.conf.update(
    task_serializer="json",
    accept_content=["json"],
    result_serializer="json",
    timezone="Asia/Kolkata",
    enable_utc=True,
)

# Celery Beat Scheduled Tasks
celery_app.conf.beat_schedule = {
    "refresh-weather-cache-15m": {
        "task": "app.workers.background_tasks.refresh_weather",
        "schedule": crontab(minute="*/15"),
    },
    "refresh-market-cache-30m": {
        "task": "app.workers.background_tasks.refresh_market",
        "schedule": crontab(minute="*/30"),
    },
    "generate-analytics-nightly": {
        "task": "app.workers.background_tasks.generate_analytics",
        "schedule": crontab(hour=2, minute=0),
    }
}
