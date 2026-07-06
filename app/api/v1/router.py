from fastapi import APIRouter

from app.api.v1.endpoints import auth, chat, document, journal, user

api_router = APIRouter(prefix="/api/v1")
api_router.include_router(auth.router)
api_router.include_router(user.router)
api_router.include_router(chat.router)
api_router.include_router(document.router)
api_router.include_router(journal.router)
