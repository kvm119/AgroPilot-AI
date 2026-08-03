import logging
from fastapi import Request
from fastapi.responses import JSONResponse
from .tracing import get_trace_id

logger = logging.getLogger("exceptions")

async def global_exception_handler(request: Request, exc: Exception):
    """
    Catches any unhandled exception in the application, logs the stack trace with the Trace ID,
    and returns a sanitized 500 response to the client.
    """
    trace_id = get_trace_id()
    
    logger.error(
        f"Unhandled Exception: {str(exc)}",
        exc_info=True,
        extra={
            "trace_id": trace_id,
            "endpoint": f"{request.method} {request.url.path}"
        }
    )
    
    return JSONResponse(
        status_code=500,
        content={
            "detail": f"Internal Server Error: {str(exc)}",
            "trace_id": trace_id
        }
    )
