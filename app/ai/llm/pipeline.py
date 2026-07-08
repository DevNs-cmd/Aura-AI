from __future__ import annotations

import time
from collections.abc import Callable
from typing import Any

from pydantic import ValidationError

from app.ai.prompt.schemas import PromptOutput

from .exceptions import LLMProviderError, LLMResponseError, LLMRetryError, LLMTransientError, LLMValidationError
from .repository import LLMRepository, build_llm_repository
from .schemas import LLMMessage, LLMRequest, LLMResponse, LLMUsage
from .utils import normalize_messages, normalize_text, sleep_for_retry


class LLMPipeline:
    def __init__(
        self,
        *,
        repository: LLMRepository,
        sleeper: Callable[[float], None] | None = None,
    ) -> None:
        self._repository = repository
        self._sleeper = sleeper

    def complete(self, request: LLMRequest | PromptOutput | dict[str, Any], db: Any | None = None) -> LLMResponse:
        llm_request = self._ensure_request(request)
        messages = llm_request.messages or [LLMMessage(role="user", content=llm_request.prompt)]
        last_error: Exception | None = None

        for attempt in range(llm_request.max_retries + 1):
            try:
                raw_response = self._repository.complete(
                    messages=messages,
                    prompt=llm_request.prompt,
                    model=llm_request.model,
                    temperature=llm_request.temperature,
                    max_tokens=llm_request.max_tokens,
                    timeout_seconds=llm_request.timeout_seconds,
                    metadata=llm_request.metadata,
                )
                return self._normalize_response(llm_request, messages, raw_response)
            except LLMTransientError as exc:
                last_error = exc
                if attempt >= llm_request.max_retries:
                    break
                sleep_for_retry(attempt, sleeper=self._sleeper or time.sleep)
            except LLMProviderError:
                raise
            except Exception as exc:  # noqa: BLE001 - adapter boundary
                raise LLMProviderError("Unexpected LLM failure") from exc

        raise LLMRetryError("LLM retries were exhausted") from last_error

    @staticmethod
    def _ensure_request(request: LLMRequest | PromptOutput | dict[str, Any]) -> LLMRequest:
        if isinstance(request, LLMRequest):
            return request
        if isinstance(request, PromptOutput):
            return LLMRequest(
                prompt=request.prompt,
                messages=normalize_messages(request.messages),
                max_tokens=request.token_budget,
            )
        try:
            return LLMRequest.model_validate(request)
        except ValidationError as exc:
            raise LLMValidationError("Invalid LLM request") from exc

    @staticmethod
    def _normalize_response(
        request: LLMRequest,
        messages: list[LLMMessage],
        raw_response: dict[str, Any],
    ) -> LLMResponse:
        choices = raw_response.get("choices")
        if not isinstance(choices, list) or not choices:
            raise LLMResponseError("LLM provider returned no choices")

        first_choice = choices[0]
        if not isinstance(first_choice, dict):
            raise LLMResponseError("LLM provider returned an invalid choice")

        message = first_choice.get("message")
        if not isinstance(message, dict):
            raise LLMResponseError("LLM provider returned an invalid message payload")

        content = normalize_text(message.get("content"))
        if content is None:
            raise LLMResponseError("LLM provider returned an empty response")

        usage_payload = raw_response.get("usage")
        usage = None
        if isinstance(usage_payload, dict):
            usage = LLMUsage.model_validate(usage_payload)

        model = normalize_text(raw_response.get("model")) or request.model or ""
        if not model:
            raise LLMResponseError("LLM provider response did not include a model")

        return LLMResponse(
            prompt=request.prompt,
            messages=messages,
            provider=normalize_text(raw_response.get("provider")) or "openrouter",
            model=model,
            content=content,
            finish_reason=normalize_text(first_choice.get("finish_reason")),
            usage=usage,
            raw_response=raw_response,
        )


def build_llm_pipeline(*, repository: LLMRepository | None = None, sleeper: Callable[[float], None] | None = None) -> LLMPipeline:
    if repository is None:
        repository = build_llm_repository()
    return LLMPipeline(repository=repository, sleeper=sleeper)
