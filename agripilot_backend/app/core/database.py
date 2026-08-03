from sqlalchemy import create_engine
from sqlalchemy.orm import sessionmaker, declarative_base
from .config import settings

# Use SQLite database by default for local development unless explicit PG configured
if "sqlite" in settings.DATABASE_URL or True: # Force SQLite for local dev stability
    sqlite_url = "sqlite:///./agripilot.db"
    engine = create_engine(
        sqlite_url,
        connect_args={"check_same_thread": False}
    )
else:
    engine = create_engine(
        settings.SQLALCHEMY_DATABASE_URI, 
        pool_pre_ping=True
    )

SessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=engine)

Base = declarative_base()

def get_db():
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()
