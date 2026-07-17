from fastapi import FastAPI, Request
from fastapi.middleware.cors import CORSMiddleware
from fastapi.responses import JSONResponse
from slowapi import Limiter, _rate_limit_exceeded_handler
from slowapi.errors import RateLimitExceeded
from slowapi.util import get_remote_address
from sqlalchemy import text

from app.api.ai import router as ai_router
from app.api.v1.router import api_router
from app.core.config import settings
from app.db.database import Base, engine
from app.models.user import User  # noqa: F401 - register table with Base.metadata
from app.models.embedding import EmbeddingRecord  # noqa: F401 - register table with Base.metadata
from app.models.journal import JournalEntry  # noqa: F401 - register table with Base.metadata

# Create tables and ensure schema migrations for local development.
# Use Alembic or a proper migration tool in production.
Base.metadata.create_all(bind=engine)
with engine.begin() as connection:
    # Ensure the users table has the active flag for FastAPI user lookup.
    connection.execute(
        text(
            "ALTER TABLE users ADD COLUMN IF NOT EXISTS is_active BOOLEAN DEFAULT TRUE NOT NULL"
        )
    )
    # Ensure the journal_entries table has the newer columns.
    connection.execute(
        text("ALTER TABLE journal_entries ADD COLUMN IF NOT EXISTS summary TEXT")
    )
    connection.execute(
        text("ALTER TABLE journal_entries ADD COLUMN IF NOT EXISTS mood VARCHAR")
    )
    connection.execute(
        text("ALTER TABLE journal_entries ADD COLUMN IF NOT EXISTS keywords JSON DEFAULT '[]'::json")
    )
    connection.execute(
        text("ALTER TABLE journal_entries ADD COLUMN IF NOT EXISTS reflection TEXT")
    )
    connection.execute(
        text("ALTER TABLE journal_entries ADD COLUMN IF NOT EXISTS follow_up_suggestions JSON DEFAULT '[]'::json")
    )
    connection.execute(
        text("ALTER TABLE journal_entries ADD COLUMN IF NOT EXISTS artifacts JSON DEFAULT '{}'::json")
    )

# B3. Rate Limiter
limiter = Limiter(key_func=get_remote_address)

app = FastAPI(title="Aura AI Backend", version="0.1.0")
app.state.limiter = limiter
app.add_exception_handler(RateLimitExceeded, _rate_limit_exceeded_handler)

# CORS - allow Flutter app to call the API
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

app.include_router(ai_router)
app.include_router(api_router)


@app.get("/health")
def health_check():
    return {"status": "ok"}


@app.exception_handler(Exception)
async def generic_exception_handler(request: Request, exc: Exception):
    return JSONResponse(status_code=500, content={"detail": "Internal server error"})
