import time
import logging
from functools import wraps

logger = logging.getLogger("db_metrics")

def track_db_metrics(query_name: str):
    """
    Decorator to track database query latency and detect slow queries.
    """
    def decorator(func):
        @wraps(func)
        async def async_wrapper(*args, **kwargs):
            start = time.time()
            try:
                result = await func(*args, **kwargs)
                latency = (time.time() - start) * 1000
                
                # SLOW QUERY DETECTION (> 200ms)
                if latency > 200:
                    logger.warning(f"SLOW DB QUERY DETECTED", extra={
                        "latency_ms": latency,
                        "metadata": {"query": query_name}
                    })
                else:
                    logger.info(f"DB Query Executed", extra={
                        "latency_ms": latency,
                        "metadata": {"query": query_name}
                    })
                return result
            except Exception as e:
                latency = (time.time() - start) * 1000
                logger.error(f"DB Query Failed", extra={
                    "latency_ms": latency,
                    "metadata": {"query": query_name, "error": str(e)}
                })
                raise e
        return async_wrapper
    return decorator
