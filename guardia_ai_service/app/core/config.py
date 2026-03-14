from pathlib import Path
from pydantic_settings import BaseSettings
from functools import lru_cache

BASE_DIR = Path(__file__).resolve().parent.parent.parent  # guardia_ai_service/


class Settings(BaseSettings):
    DATABASE_URL: str = "mysql+aiomysql://root:password@localhost:3306/guardia"
    FIREBASE_PROJECT_ID: str = ""
    FIREBASE_CLIENT_EMAIL: str = ""
    FIREBASE_PRIVATE_KEY: str = ""
    CORS_ORIGINS: list[str] = ["*"]
    DBSCAN_EPS_KM: float = 0.3
    DBSCAN_MIN_SAMPLES: int = 3
    RISK_DECAY_DAYS: int = 30

    model_config = {"env_file": str(BASE_DIR / ".env"), "extra": "ignore"}


@lru_cache
def get_settings() -> Settings:
    return Settings()
