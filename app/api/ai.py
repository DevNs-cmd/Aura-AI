from __future__ import annotations

from datetime import datetime, timezone

from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session

from app.api.deps import get_ai_chat_service, get_db
from app.ai.chat.exceptions import ChatError
from app.ai.chat.service import ChatService
from app.models.user import User
from app.schemas.ai_chat import AIChatMetadata, AIChatRequest, AIChatResponse
from app.ai.chat.schemas import ChatRequest

router = APIRouter(prefix="/ai", tags=["AI Gateway"])


@router.post("/chat", response_model=AIChatResponse)
def chat(
    request: AIChatRequest,
    db: Session = Depends(get_db),
    chat_service: ChatService = Depends(get_ai_chat_service),
) -> AIChatResponse:
    user = db.query(User).filter(User.id == request.user_id).first()
    if user is None or not user.is_active:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="User not found")

    try:
        result = chat_service.generate_reply(ChatRequest(user_id=user.id, query=request.message), db=db)
    except ChatError as exc:
        raise HTTPException(status_code=status.HTTP_502_BAD_GATEWAY, detail="AI chat generation failed") from exc

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
