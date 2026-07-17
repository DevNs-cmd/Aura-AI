from __future__ import annotations

from typing import Any, Literal

from pydantic import BaseModel, ConfigDict, Field


class LLMMessage(BaseModel):
    model_config = ConfigDict(extra="forbid")

    role: Literal["system", "developer", "user", "assistant"]
    content: str = Field(min_length=1)


class LLMRequest(BaseModel):
    prompt: str = Field(min_length=1)
    messages: list[LLMMessage] = Field(default_factory=list)
    model: str | None = None
    temperature: float | None = Field(default=None, ge=0, le=2)
    max_tokens: int | None = Field(default=None, ge=1)
    max_retries: int = Field(default=3, ge=0)
    timeout_seconds: int = Field(default=30, ge=1)
    metadata: dict[str, Any] = Field(default_factory=dict)


class LLMUsage(BaseModel):
    model_config = ConfigDict(extra="ignore")

    prompt_tokens: int | None = Field(default=None, ge=0)
    completion_tokens: int | None = Field(default=None, ge=0)
    total_tokens: int | None = Field(default=None, ge=0)


class LLMResponse(BaseModel):
    model_config = ConfigDict(from_attributes=True)

    prompt: str
    messages: list[LLMMessage] = Field(default_factory=list)
    provider: str
    model: str
    content: str = Field(min_length=1)
    finish_reason: str | None = None
    usage: LLMUsage | None = None
    raw_response: dict[str, Any] = Field(default_factory=dict)
