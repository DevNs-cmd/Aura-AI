from __future__ import annotations

from typing import Any

from pydantic import ValidationError

from .exceptions import ChatError, ChatPipelineError, ChatValidationError
from .pipeline import ChatPipeline, build_chat_pipeline
from .schemas import ChatRequest, ChatResponse


class ChatService:
    def __init__(self, *, pipeline: ChatPipeline) -> None:
        self._pipeline = pipeline

    def generate_reply(self, request: ChatRequest | dict[str, Any], db: Any | None = None) -> ChatResponse:
        try:
            return self._pipeline.generate_reply(request=request, db=db)
        except ChatError:
            raise
        except ValidationError as exc:
            raise ChatValidationError("Invalid chat request") from exc
        except Exception as exc:  # noqa: BLE001 - service boundary
            raise ChatPipelineError("Failed to generate chat reply") from exc


def build_chat_service(*, pipeline: ChatPipeline | None = None, **kwargs: Any) -> ChatService:
    if pipeline is None:
        pipeline = build_chat_pipeline(**kwargs)
    return ChatService(pipeline=pipeline)
