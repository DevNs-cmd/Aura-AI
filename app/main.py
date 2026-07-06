from fastapi import FastAPI, Request
from fastapi.middleware.cors import CORSMiddleware
from fastapi.responses import JSONResponse
from slowapi import Limiter, _rate_limit_exceeded_handler
from slowapi.errors import RateLimitExceeded
from slowapi.util import get_remote_address

from app.api.v1.router import api_router
from app.core.config import settings
from app.db.database import Base, engine
from app.models.embedding import EmbeddingRecord  # noqa: F401 - register table with Base.metadata
from app.models.journal import JournalEntry  # noqa: F401 - register table with Base.metadata

# Create tables (use Alembic migrations in production instead)
Base.metadata.create_all(bind=engine)

# B3. Rate Limiter
limiter = Limiter(key_func=get_remote_address)

app = FastAPI(title="Aura AI Backend", version="0.1.0")
app.state.limiter = limiter
app.add_exception_handler(RateLimitExceeded, _rate_limit_exceeded_handler)

# CORS - allow Flutter app to call the API
app.add_middleware(
    CORSMiddleware,
    allow_origins=[settings.FRONTEND_URL, "*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

app.include_router(api_router)


@app.get("/health")
def health_check():
    return {"status": "ok"}


@app.exception_handler(Exception)
async def generic_exception_handler(request: Request, exc: Exception):
    return JSONResponse(status_code=500, content={"detail": "Internal server error"})
