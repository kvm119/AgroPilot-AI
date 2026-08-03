import time
import logging
from typing import Dict, List
import statistics

logger = logging.getLogger(__name__)

class RequestProfiler:
    """
    Captures exact timing across the Orchestrator lifecycle to identify latency bottlenecks.
    """
    def __init__(self):
        self.endpoint_timings: Dict[str, List[float]] = {}
        
    def record_latency(self, endpoint: str, latency_ms: float):
        if endpoint not in self.endpoint_timings:
            self.endpoint_timings[endpoint] = []
        self.endpoint_timings[endpoint].append(latency_ms)
        
    def get_percentiles(self, endpoint: str) -> Dict[str, float]:
        timings = self.endpoint_timings.get(endpoint, [])
        if not timings:
            return {"P50": 0.0, "P90": 0.0, "P95": 0.0, "P99": 0.0}
            
        sorted_timings = sorted(timings)
        return {
            "P50": round(statistics.quantiles(sorted_timings, n=100)[49] if len(sorted_timings) > 100 else sorted_timings[len(sorted_timings)//2], 2),
            "P90": round(statistics.quantiles(sorted_timings, n=100)[89] if len(sorted_timings) > 100 else sorted_timings[int(len(sorted_timings)*0.9)], 2),
            "P95": round(statistics.quantiles(sorted_timings, n=100)[94] if len(sorted_timings) > 100 else sorted_timings[int(len(sorted_timings)*0.95)], 2),
            "P99": round(statistics.quantiles(sorted_timings, n=100)[98] if len(sorted_timings) > 100 else sorted_timings[-1], 2),
        }

profiler = RequestProfiler()
