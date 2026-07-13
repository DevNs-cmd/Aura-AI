from __future__ import annotations

from datetime import datetime
from uuid import UUID

from pydantic import BaseModel, ConfigDict, Field


class AIChatRequest(BaseModel):
    user_id: UUID
    message: str = Field(min_length=1)


class AIChatMetadata(BaseModel):
    model_config = ConfigDict(from_attributes=True)

    memory_used: bool = False
    rag_used: bool = False


class AIChatResponse(BaseModel):
    model_config = ConfigDict(from_attributes=True)

    reply: str = Field(min_length=1)
    model_used: str = Field(min_length=1)
    timestamp: datetime
    metadata: AIChatMetadata
