from __future__ import annotations

from typing import Any

from pydantic import ValidationError

from .exceptions import LLMError, LLMProviderError, LLMValidationError
from .pipeline import LLMPipeline, build_llm_pipeline
from app.ai.prompt.schemas import PromptOutput

from .schemas import LLMRequest, LLMResponse


class LLMService:
    def __init__(self, *, pipeline: LLMPipeline) -> None:
        self._pipeline = pipeline

    def complete(self, request: LLMRequest | PromptOutput | dict[str, Any], db: Any | None = None) -> LLMResponse:
        try:
            return self._pipeline.complete(request, db=db)
        except LLMError:
            raise
        except ValidationError as exc:
            raise LLMValidationError("Invalid LLM request") from exc
        except Exception as exc:  # noqa: BLE001 - service boundary
            raise LLMProviderError("Failed to complete LLM request") from exc


def build_llm_service(*, pipeline: LLMPipeline | None = None) -> LLMService:
    if pipeline is None:
        pipeline = build_llm_pipeline()
    return LLMService(pipeline=pipeline)
