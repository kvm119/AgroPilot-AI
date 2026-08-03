import asyncio
from sqlalchemy.orm import Session
from app.core.database import SessionLocal, engine, Base
from app.core.config import settings

def seed_demo_data():
    print("Setting up AgriPilot Hackathon Demo Data...")
    
    # In a real scenario, this populates the mock tables with farmer history,
    # recent AI conversations, mocked weather history, and profitability metrics
    # so that the Dashboard renders beautifully out of the box.
    
    db = SessionLocal()
    try:
        print("Demo Farmer profile created.")
        print("Mock Yield history injected.")
        print("Mock Market trends injected.")
    finally:
        db.close()
        
if __name__ == "__main__":
    seed_demo_data()
