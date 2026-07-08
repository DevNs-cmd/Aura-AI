from __future__ import annotations

import time
from collections.abc import Iterable, Mapping, Sequence
from typing import Any

from .schemas import LLMMessage


def normalize_text(value: Any) -> str | None:
    if value is None:
        return None
    text = str(value).strip()
    return text or None


def normalize_messages(messages: Iterable[LLMMessage | Mapping[str, Any]]) -> list[LLMMessage]:
    normalized: list[LLMMessage] = []
    for message in messages:
        if isinstance(message, LLMMessage):
            normalized.append(message)
            continue
        if hasattr(message, "model_dump"):
            normalized.append(LLMMessage.model_validate(message.model_dump()))
            continue
        normalized.append(LLMMessage.model_validate(message))
    return normalized


def normalize_message_payloads(messages: Sequence[LLMMessage]) -> list[dict[str, str]]:
    return [{"role": message.role, "content": message.content} for message in messages]


def is_retryable_status(status_code: int | None) -> bool:
    return status_code in {408, 409, 425, 429, 500, 502, 503, 504}


def backoff_delay(attempt: int, *, base_seconds: float = 0.2, max_seconds: float = 2.0) -> float:
    return min(max_seconds, base_seconds * (2**attempt))


def sleep_for_retry(attempt: int, *, sleeper: Any = time.sleep) -> None:
    sleeper(backoff_delay(attempt))
