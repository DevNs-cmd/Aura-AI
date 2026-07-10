from __future__ import annotations

from typing import Any

from app.ai.journal.schemas import JournalEntryCreate
from app.ai.llm.schemas import LLMResponse
from app.ai.memory.schemas import MemoryCreate

from .schemas import ChatRequest


def normalize_text(value: Any) -> str | None:
    if value is None:
        return None
    text = str(value).strip()
    return text or None


def build_default_memory_payloads(request: ChatRequest, response: LLMResponse) -> list[MemoryCreate]:
    return [
        MemoryCreate(
            user_id=request.user_id,
            key="chat:last_assistant_reply",
            value=response.content,
            source="chat",
        )
    ]


def build_default_journal_payload(request: ChatRequest, response: LLMResponse) -> JournalEntryCreate:
    title = normalize_text(request.query) or "Chat response"
    title = title[:255]
    return JournalEntryCreate(title=title, content=response.content)
