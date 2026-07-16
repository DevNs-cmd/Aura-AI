from __future__ import annotations

import logging
from datetime import datetime, timezone

from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session

from app.api.deps import get_ai_chat_service, get_db
from app.ai.chat.exceptions import ChatError
from app.ai.chat.service import ChatService
from app.core.security import hash_password
from app.models.user import User
from app.schemas.ai_chat import AIChatMetadata, AIChatRequest, AIChatResponse
from app.ai.chat.schemas import ChatRequest

logger = logging.getLogger(__name__)

router = APIRouter(prefix="/ai", tags=["AI Gateway"])


@router.post("/chat", response_model=AIChatResponse)
def chat(
    request: AIChatRequest,
    db: Session = Depends(get_db),
    chat_service: ChatService = Depends(get_ai_chat_service),
) -> AIChatResponse:
    user = None

    if request.user_id is not None:
        user = db.query(User).filter(User.id == request.user_id).first()

    if user is None and request.user_email is not None:
        user = db.query(User).filter(User.email.ilike(request.user_email)).first()

    if user is None and request.user_email is not None:
        raw_password = request.user_email + (str(request.user_id) if request.user_id is not None else "")
        if len(raw_password) > 72:
            raw_password = raw_password[:72]

        user_kwargs = {
            "email": request.user_email,
            "name": request.user_name or request.user_email.split("@")[0],
            "password_hash": hash_password(raw_password),
        }
        if request.user_id is not None:
            user_kwargs["id"] = request.user_id

        user = User(**user_kwargs)
        db.add(user)
        db.commit()
        db.refresh(user)

    if user is None or not user.is_active:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="User not found")

    try:
        result = chat_service.generate_reply(ChatRequest(user_id=user.id, query=request.message), db=db)
    except ChatError as exc:
        logger.exception("AI chat generation failed for user_id=%s", user.id)
        raise HTTPException(
            status_code=status.HTTP_502_BAD_GATEWAY,
            detail=str(exc) if str(exc) else "AI chat generation failed",
        ) from exc

    metadata = AIChatMetadata(
        memory_used=bool(result.context.memory.memories or result.context.memory.summary),
        rag_used=bool(result.context.retrieval.documents or result.context.retrieval.summary),
    )

    return AIChatResponse(
        reply=result.response.content,
        model_used=result.response.model,
        timestamp=datetime.now(timezone.utc),
        metadata=metadata,
    )
