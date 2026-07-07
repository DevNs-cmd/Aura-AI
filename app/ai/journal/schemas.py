from __future__ import annotations

from datetime import datetime
from typing import Any
from uuid import UUID

from pydantic import BaseModel, ConfigDict, Field


class JournalEntryCreate(BaseModel):
    title: str = Field(min_length=1, max_length=255)
    content: str = Field(min_length=1, max_length=20000)


class JournalEntryUpdate(BaseModel):
    title: str | None = Field(default=None, min_length=1, max_length=255)
    content: str | None = Field(default=None, min_length=1, max_length=20000)


class JournalInsightRead(BaseModel):
    keywords: list[str] = Field(default_factory=list)
    mood: str
    summary: str


class JournalReflectionRead(BaseModel):
    reflection: str
    follow_up_suggestions: list[str] = Field(default_factory=list)


class JournalArtifactUpdate(BaseModel):
    summary: str | None = None
    mood: str | None = None
    keywords: list[str] = Field(default_factory=list)
    reflection: str | None = None
    follow_up_suggestions: list[str] = Field(default_factory=list)
    embedding_id: str | None = None


class JournalMemorySeed(BaseModel):
    user_id: UUID
    key: str = Field(min_length=1)
    value: str = Field(min_length=1)
    source: str = Field(default="journal", min_length=1)


class JournalEntryRead(JournalEntryCreate):
    id: UUID
    user_id: UUID
    summary: str | None = None
    mood: str | None = None
    keywords: list[str] = Field(default_factory=list)
    reflection: str | None = None
    follow_up_suggestions: list[str] = Field(default_factory=list)
    artifacts: dict[str, Any] = Field(default_factory=dict)
    deleted_at: datetime | None = None
    created_at: datetime
    updated_at: datetime

    model_config = ConfigDict(from_attributes=True)


class JournalPipelineInput(BaseModel):
    user_id: UUID
    title: str
    content: str


class JournalPipelineResult(BaseModel):
    entry: JournalEntryRead
    insights: JournalInsightRead
    reflection: JournalReflectionRead
    artifacts: JournalArtifactUpdate
    memory_payloads: list[JournalMemorySeed] = Field(default_factory=list)
    embedding_id: str
    vector: list[float]
