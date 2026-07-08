from __future__ import annotations

from typing import Any
from uuid import UUID

from pydantic import BaseModel, ConfigDict, Field

from app.ai.context.schemas import AIContext
from app.ai.llm.schemas import LLMResponse
from app.ai.prompt.schemas import PromptOutput


class ChatRequest(BaseModel):
    user_id: UUID | str
    query: str = Field(min_length=1)
    session_id: UUID | str | None = None
    conversation_id: UUID | str | None = None
    memory_limit: int = Field(default=20, ge=0)
    journal_limit: int = Field(default=5, ge=0)
    retrieval_limit: int = Field(default=5, ge=0)
    token_budget: int = Field(default=2048, ge=1)
    persist_memory: bool = True
    persist_journal: bool = True


class ChatResponse(BaseModel):
    model_config = ConfigDict(from_attributes=True)

    request: ChatRequest
    context: AIContext
    prompt: PromptOutput
    response: LLMResponse
    memory_updates: list[dict[str, Any]] = Field(default_factory=list)
    journal_updates: list[dict[str, Any]] = Field(default_factory=list)
