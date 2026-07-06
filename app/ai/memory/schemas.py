from __future__ import annotations

from datetime import datetime
from uuid import UUID

from pydantic import BaseModel, ConfigDict, Field


class MemoryCreate(BaseModel):
    user_id: UUID
    key: str = Field(min_length=1)
    value: str = Field(min_length=1)
    source: str = Field(default="chat", min_length=1)


class MemoryUpdate(BaseModel):
    key: str | None = Field(default=None, min_length=1)
    value: str | None = Field(default=None, min_length=1)
    source: str | None = Field(default=None, min_length=1)


class MemoryRead(MemoryCreate):
    id: UUID
    created_at: datetime
    updated_at: datetime

    model_config = ConfigDict(from_attributes=True)


class MemoryRetrievalResult(BaseModel):
    memory: MemoryRead
    score: float
    vector_score: float
    recency_score: float
    lexical_score: float

    model_config = ConfigDict(from_attributes=True)
