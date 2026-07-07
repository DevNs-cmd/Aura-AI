from __future__ import annotations

from datetime import datetime, timezone
from typing import Any
from uuid import UUID

from pydantic import BaseModel, ConfigDict, Field


class ContextRequest(BaseModel):
    user_id: UUID | str
    query: str = Field(min_length=1)
    session_id: UUID | str | None = None
    conversation_id: UUID | str | None = None
    memory_limit: int = Field(default=20, ge=0)
    journal_limit: int = Field(default=5, ge=0)
    retrieval_limit: int = Field(default=5, ge=0)


class ConversationContext(BaseModel):
    query: str
    session_id: UUID | str | None = None
    messages: list[dict[str, str]] = Field(default_factory=list)
    summary: str | None = None


class MemoryContext(BaseModel):
    memories: list[dict[str, Any]] = Field(default_factory=list)
    summary: str | None = None


class JournalContext(BaseModel):
    entries: list[dict[str, Any]] = Field(default_factory=list)
    insights: list[str] = Field(default_factory=list)
    summary: str | None = None


class RetrievalContext(BaseModel):
    documents: list[dict[str, Any]] = Field(default_factory=list)
    query: str | None = None
    summary: str | None = None


class AIContext(BaseModel):
    model_config = ConfigDict(from_attributes=True)

    request: ContextRequest
    conversation: ConversationContext
    memory: MemoryContext = Field(default_factory=MemoryContext)
    journal: JournalContext = Field(default_factory=JournalContext)
    retrieval: RetrievalContext = Field(default_factory=RetrievalContext)
    created_at: datetime = Field(default_factory=lambda: datetime.now(timezone.utc))


class ContextResponse(BaseModel):
    model_config = ConfigDict(from_attributes=True)

    context: AIContext
