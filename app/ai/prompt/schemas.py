from __future__ import annotations

from typing import Literal
from uuid import UUID

from pydantic import BaseModel, ConfigDict, Field


class PromptMessage(BaseModel):
    model_config = ConfigDict(extra="forbid")

    role: Literal["system", "developer", "user", "assistant"]
    content: str = Field(min_length=1)


class PromptInput(BaseModel):
    user_id: UUID | str
    query: str = Field(min_length=1)
    session_id: UUID | str | None = None
    conversation_id: UUID | str | None = None
    memory_limit: int = Field(default=20, ge=0)
    journal_limit: int = Field(default=5, ge=0)
    retrieval_limit: int = Field(default=5, ge=0)
    token_budget: int = Field(default=2048, ge=1)


class PromptOutput(BaseModel):
    model_config = ConfigDict(from_attributes=True)

    messages: list[PromptMessage]
    prompt: str
    token_count: int
    token_budget: int
