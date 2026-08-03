from pydantic_settings import BaseSettings

class Settings(BaseSettings):
    PROJECT_NAME: str = "AgriPilot Backend"
    VERSION: str = "1.0.0"
    API_V1_STR: str = "/api/v1"
    
    # Environment Variables
    DATABASE_URL: str = "postgresql://postgres:postgres@localhost:5432/agripilot"
    REDIS_URL: str = "redis://localhost:6379/0"
    CELERY_BROKER_URL: str = "redis://localhost:6379/1"
    
    # Secrets (Loaded from .env in dev, or Secret Manager in prod)
    JWT_SECRET: str = "super_secret_key"
    GEMINI_API_KEY: str = ""
    OPENWEATHER_API_KEY: str = ""

    @property
    def SQLALCHEMY_DATABASE_URI(self) -> str:
        return self.DATABASE_URL
    
    class Config:
        env_file = ".env"

settings = Settings()

