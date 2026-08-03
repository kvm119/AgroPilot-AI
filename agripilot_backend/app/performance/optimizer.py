import logging

logger = logging.getLogger(__name__)

class OptimizerBase:
    """
    Base utility for general performance optimizations.
    """
    @staticmethod
    def log_optimization(module: str, action: str):
        logger.info(f"[OPTIMIZED] Module: {module} | Action: {action}")
