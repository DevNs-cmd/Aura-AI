from __future__ import annotations

from typing import Any, Protocol, Sequence

import requests

from app.core.config import settings

from .exceptions import LLMConfigurationError, LLMProviderError, LLMTransientError
from .schemas import LLMMessage
from .utils import normalize_message_payloads

OPENROUTER_URL = "https://openrouter.ai/api/v1/chat/completions"


class LLMRepository(Protocol):
    provider_name: str
    model_name: str

    def complete(
        self,
        *,
        messages: Sequence[LLMMessage],
        prompt: str,
        model: str | None = None,
        temperature: float | None = None,
        max_tokens: int | None = None,
        timeout_seconds: int = 30,
        metadata: dict[str, Any] | None = None,
    ) -> dict[str, Any]:
        ...


class OpenRouterLLMRepository:
    def __init__(
        self,
        *,
        api_key: str,
        model_name: str,
        referer: str | None = None,
        title: str = "Aura AI",
    ) -> None:
        if not api_key:
            raise LLMConfigurationError("OPENROUTER_API_KEY is required")
        if not model_name:
            raise LLMConfigurationError("LLM model name is required")

        self.provider_name = "openrouter"
        self.model_name = model_name
        self.api_key = api_key
        self.referer = referer
        self.title = title

    def _headers(self) -> dict[str, str]:
        headers = {
            "Authorization": f"Bearer {self.api_key}",
            "Content-Type": "application/json",
        }
        if self.referer:
            headers["HTTP-Referer"] = self.referer
        if self.title:
            headers["X-Title"] = self.title
        return headers

    @staticmethod
    def _is_transient_response(response: requests.Response | None) -> bool:
        if response is None:
            return True
        return response.status_code in {408, 409, 425, 429, 500, 502, 503, 504}

    def complete(
        self,
        *,
        messages: Sequence[LLMMessage],
        prompt: str,
        model: str | None = None,
        temperature: float | None = None,
        max_tokens: int | None = None,
        timeout_seconds: int = 30,
        metadata: dict[str, Any] | None = None,
    ) -> dict[str, Any]:
        payload: dict[str, Any] = {
            "model": model or self.model_name,
            "messages": normalize_message_payloads(messages),
        }
        if temperature is not None:
            payload["temperature"] = temperature
        if max_tokens is not None:
            payload["max_tokens"] = max_tokens
        if metadata:
            payload["metadata"] = metadata

        try:
            response = requests.post(
                OPENROUTER_URL,
                headers=self._headers(),
                json=payload,
                timeout=timeout_seconds,
            )
            response.raise_for_status()
            data = response.json()
            if not isinstance(data, dict):
                raise ValueError("LLM response must be a JSON object")
            return data
        except requests.Timeout as exc:
            raise LLMTransientError("LLM request timed out") from exc
        except requests.RequestException as exc:
            response = getattr(exc, "response", None)
            if self._is_transient_response(response):
                raise LLMTransientError("LLM request failed transiently") from exc
            raise LLMProviderError("LLM request failed") from exc
        except ValueError as exc:
            raise LLMProviderError("LLM provider returned invalid JSON") from exc


def build_llm_repository() -> LLMRepository:
    return OpenRouterLLMRepository(
        api_key=settings.OPENROUTER_API_KEY,
        model_name=settings.LLM_MODEL,
        referer=settings.FRONTEND_URL,
    )
