import json
import logging
from datetime import datetime
from typing import Any, Dict
from .tracing import get_trace_id, get_request_id, user_id_ctx

class StructuredJSONFormatter(logging.Formatter):
    """
    Forces all logs to output as structured JSON so Datadog/ELK can parse them instantly.
    """
    def format(self, record: logging.LogRecord) -> str:
        log_obj: Dict[str, Any] = {
            "timestamp": datetime.utcnow().isoformat() + "Z",
            "level": record.levelname,
            "logger_name": record.name,
            "trace_id": get_trace_id(),
            "request_id": get_request_id(),
            "user_id": user_id_ctx.get(),
            "message": record.getMessage(),
        }

        if record.exc_info:
            log_obj["exception"] = self.formatException(record.exc_info)
            
        if hasattr(record, "latency_ms"):
            log_obj["latency_ms"] = record.latency_ms
            
        if hasattr(record, "metadata"):
            log_obj["metadata"] = record.metadata

        return json.dumps(log_obj)

def setup_structured_logging():
    handler = logging.StreamHandler()
    handler.setFormatter(StructuredJSONFormatter())
    
    # Apply to root logger
    root = logging.getLogger()
    root.setLevel(logging.INFO)
    
    # Remove existing handlers to prevent duplicate raw logs
    for h in root.handlers[:]:
        root.removeHandler(h)
        
    root.addHandler(handler)

# Initialize on import
setup_structured_logging()
logger = logging.getLogger(__name__)
