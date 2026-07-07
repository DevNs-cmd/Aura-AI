from __future__ import annotations

from datetime import datetime
from typing import Any
from uuid import UUID

from pydantic import BaseModel, ConfigDict, Field


class RagRetrievalRequest(BaseModel):
    query: str = Field(min_length=1)
    top_k: int = Field(default=5, ge=1)


class RagDocumentMetadata(BaseModel):
    id: UUID
    user_id: UUID
    filename: str
    file_path: str
    file_type: str | None = None
    size_bytes: int | None = None
    status: str
    created_at: datetime

    model_config = ConfigDict(from_attributes=True)


class RagRetrievalResult(BaseModel):
    document_id: UUID
    chunk_id: str
    chunk_text: str
    similarity_score: float
    metadata: dict[str, Any] = Field(default_factory=dict)

    model_config = ConfigDict(from_attributes=True)
