from __future__ import annotations

import json
import math
from collections.abc import Iterable, Mapping, Sequence
from typing import Any

from .schemas import PromptMessage


def normalize_text(value: Any) -> str | None:
    if value is None:
        return None
    text = str(value).strip()
    return text or None


def normalize_messages(messages: Iterable[PromptMessage | Mapping[str, Any]]) -> list[PromptMessage]:
    normalized: list[PromptMessage] = []
    for message in messages:
        if isinstance(message, PromptMessage):
            normalized.append(message)
            continue
        normalized.append(PromptMessage.model_validate(message))
    return normalized


def estimate_token_count(text: str | None) -> int:
    normalized = normalize_text(text)
    if normalized is None:
        return 0
    return max(1, math.ceil(len(normalized) / 4))


def estimate_prompt_tokens(messages: Sequence[PromptMessage]) -> int:
    return sum(estimate_token_count(message.content) + 4 for message in messages)


def truncate_text(text: str, token_budget: int) -> str:
    normalized = normalize_text(text)
    if normalized is None or token_budget <= 0:
        return ""
    char_budget = max(1, token_budget * 4)
    if len(normalized) <= char_budget:
        return normalized
    return normalized[:char_budget].rstrip()


def stable_json(value: Any) -> str:
    return json.dumps(value, ensure_ascii=False, sort_keys=True, separators=(", ", ": "))


def render_mapping(mapping: Mapping[str, Any]) -> str:
    parts: list[str] = []
    for key in sorted(mapping):
        value = mapping[key]
        if value is None:
            continue
        if isinstance(value, str):
            cleaned = normalize_text(value)
            if cleaned is None:
                continue
            parts.append(f"{key}={cleaned}")
            continue
        if isinstance(value, Mapping) or isinstance(value, list):
            parts.append(f"{key}={stable_json(value)}")
            continue
        parts.append(f"{key}={value}")
    return " | ".join(parts)


def render_section(title: str, lines: Sequence[str]) -> str:
    normalized_lines = [line for line in (normalize_text(line) for line in lines) if line]
    if not normalized_lines:
        return ""
    body = "\n".join(f"- {line}" for line in normalized_lines)
    return f"{title}:\n{body}"

