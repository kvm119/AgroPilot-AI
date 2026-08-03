import logging

logger = logging.getLogger(__name__)

class LoadTester:
    """
    Generates Locust-compatible load testing scripts for AgriPilot.
    """
    
    @staticmethod
    def generate_locustfile() -> str:
        logger.info("Generating Locust stress test definitions...")
        return """
from locust import HttpUser, task, between

class AgriPilotUser(HttpUser):
    wait_time = between(1, 5)

    @task(3)
    def view_dashboard(self):
        self.client.get("/api/v1/analytics/demo_farm/dashboard")

    @task(1)
    def ask_copilot(self):
        self.client.post("/api/v1/copilot/chat", json={
            "user_id": "demo_farm",
            "message": "What is the weather like today?"
        })
"""
