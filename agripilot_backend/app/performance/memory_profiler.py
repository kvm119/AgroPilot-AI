import tracemalloc
import logging

logger = logging.getLogger(__name__)

class MemoryProfiler:
    """
    Detects memory leaks in long-running async environments.
    """
    @staticmethod
    def start():
        tracemalloc.start()
        logger.info("Memory Profiler started.")
        
    @staticmethod
    def snapshot(top_n: int = 10):
        snapshot = tracemalloc.take_snapshot()
        top_stats = snapshot.statistics('lineno')
        
        logger.info(f"--- Top {top_n} Memory Allocations ---")
        for stat in top_stats[:top_n]:
            logger.info(stat)
            
    @staticmethod
    def stop():
        tracemalloc.stop()
        logger.info("Memory Profiler stopped.")
