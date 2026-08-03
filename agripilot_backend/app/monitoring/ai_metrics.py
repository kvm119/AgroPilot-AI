import time
import logging
from functools import wraps

logger = logging.getLogger("ai_metrics")

def track_ai_metrics(tool_name: str):
    """
    Decorator to track latency and token usage of AI Services.
    """
    def decorator(func):
        @wraps(func)
        async def async_wrapper(*args, **kwargs):
            start = time.time()
            try:
                result = await func(*args, **kwargs)
                latency = (time.time() - start) * 1000
                logger.info(f"AI Execution Successful", extra={
                    "latency_ms": latency,
                    "metadata": {"tool": tool_name}
                })
                return result
            except Exception as e:
                latency = (time.time() - start) * 1000
                logger.error(f"AI Execution Failed: {str(e)}", extra={
                    "latency_ms": latency,
                    "metadata": {"tool": tool_name, "error": str(e)}
                })
                raise e
                
        @wraps(func)
        def sync_wrapper(*args, **kwargs):
            start = time.time()
            try:
                result = func(*args, **kwargs)
                latency = (time.time() - start) * 1000
                logger.info(f"AI Execution Successful", extra={
                    "latency_ms": latency,
                    "metadata": {"tool": tool_name}
                })
                return result
            except Exception as e:
                latency = (time.time() - start) * 1000
                logger.error(f"AI Execution Failed: {str(e)}", extra={
                    "latency_ms": latency,
                    "metadata": {"tool": tool_name, "error": str(e)}
                })
                raise e
                
        if getattr(func, '_is_coroutine', False) or __import__('asyncio').iscoroutinefunction(func):
            return async_wrapper
        return sync_wrapper
    return decorator
