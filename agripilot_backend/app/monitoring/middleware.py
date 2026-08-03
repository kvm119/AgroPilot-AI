import time
import logging
from fastapi import Request
from starlette.middleware.base import BaseHTTPMiddleware
from .tracing import trace_id_ctx, request_id_ctx, generate_trace_id, generate_request_id
from .metrics import global_metrics

logger = logging.getLogger("http_middleware")

class ObservabilityMiddleware(BaseHTTPMiddleware):
    async def dispatch(self, request: Request, call_next):
        # 1. Generate Context IDs
        request_id = generate_request_id()
        trace_id = request.headers.get("X-Trace-Id", generate_trace_id())
        
        # Set ContextVars for this async execution tree
        request_id_ctx.set(request_id)
        trace_id_ctx.set(trace_id)
        
        start_time = time.time()
        
        try:
            # 2. Process Request
            response = await call_next(request)
            
            # 3. Calculate Latency
            latency_ms = (time.time() - start_time) * 1000
            
            # 4. Inject Headers
            response.headers["X-Request-Id"] = request_id
            response.headers["X-Trace-Id"] = trace_id
            
            # 5. Record Metrics
            global_metrics.record_request(request.url.path, latency_ms, response.status_code)
            
            # 6. Structured Logging
            logger.info(
                f"HTTP {request.method} {request.url.path} - {response.status_code}",
                extra={
                    "latency_ms": round(latency_ms, 2),
                    "status_code": response.status_code,
                    "endpoint": request.url.path
                }
            )
            
            return response
            
        except Exception as e:
            latency_ms = (time.time() - start_time) * 1000
            global_metrics.record_request(request.url.path, latency_ms, 500)
            logger.error(f"Request failed on {request.url.path}: {str(e)}", exc_info=True)
            from fastapi.responses import JSONResponse
            return JSONResponse(
                status_code=500,
                content={"detail": f"Server Error: {str(e)}", "error_type": type(e).__name__}
            )
