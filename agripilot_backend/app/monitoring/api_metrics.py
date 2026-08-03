import time
import logging
from functools import wraps

logger = logging.getLogger("api_metrics")

def track_api_metrics(api_name: str):
    """
    Decorator to track 3rd party API reliability (Weather, Market, Govt).
    """
    def decorator(func):
        @wraps(func)
        async def async_wrapper(*args, **kwargs):
            start = time.time()
            try:
                result = await func(*args, **kwargs)
                latency = (time.time() - start) * 1000
                logger.info(f"External API Success", extra={
                    "latency_ms": latency,
                    "metadata": {"api": api_name, "status": "up"}
                })
                return result
            except Exception as e:
                latency = (time.time() - start) * 1000
                logger.error(f"External API Failure", extra={
                    "latency_ms": latency,
                    "metadata": {"api": api_name, "status": "down", "error": str(e)}
                })
                raise e
        return async_wrapper
    return decorator
