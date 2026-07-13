from pydantic_settings import BaseSettings, SettingsConfigDict


class Settings(BaseSettings):
    # Database
    DATABASE_URL: str = "postgresql://aura_user:aura_db_ai_pass@localhost:5432/aura_ai"



    # Redis
    REDIS_URL: str = "redis://localhost:6379/0"

    # JWT
    SECRET_KEY: str = "change-this-to-a-random-secret-key"
    ALGORITHM: str = "HS256"
    ACCESS_TOKEN_EXPIRE_MINUTES: int = 60
    REFRESH_TOKEN_EXPIRE_DAYS: int = 7

    # LLM
    OPENROUTER_API_KEY: str = ""
    LLM_MODEL: str = "google/gemini-2.0-flash-exp:free"

    # Embeddings
    EMBEDDING_PROVIDER: str = "http"
    EMBEDDING_MODEL: str = "aura-embedding-model"
    EMBEDDING_API_URL: str = ""
    EMBEDDING_API_KEY: str = ""
    EMBEDDING_TIMEOUT_SECONDS: int = 30
    EMBEDDING_DIMENSION: int = 64
    CHROMA_PERSIST_DIRECTORY: str = "./chroma"
    CHROMA_COLLECTION_NAME: str = "aura_embeddings"

    # App
    ENVIRONMENT: str = "development"
    FRONTEND_URL: str = "http://localhost:5173"

    model_config = SettingsConfigDict(
        env_file=None,
        extra="ignore",
        case_sensitive=False,
    )


settings = Settings()
