import time
import logging
from functools import wraps
from typing import Dict, Any

logger = logging.getLogger("metrics")

class MetricsEngine:
    """
    In-memory aggregator for MVP. Production should use Prometheus client.
    """
    def __init__(self):
        self.request_counts = {}
        self.latencies = []
        self.errors = 0
        
    def record_request(self, endpoint: str, latency_ms: float, status_code: int):
        self.request_counts[endpoint] = self.request_counts.get(endpoint, 0) + 1
        self.latencies.append(latency_ms)
        if status_code >= 400:
            self.errors += 1
            
    def get_summary(self) -> Dict[str, Any]:
        avg = sum(self.latencies) / len(self.latencies) if self.latencies else 0
        return {
            "total_requests": sum(self.request_counts.values()),
            "average_latency_ms": round(avg, 2),
            "error_count": self.errors
        }

global_metrics = MetricsEngine()
