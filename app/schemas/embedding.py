from __future__ import annotations

from datetime import datetime

from pydantic import BaseModel, ConfigDict, Field


class EmbeddingRequest(BaseModel):
    text: str = Field(min_length=1)


class EmbeddingBatchRequest(BaseModel):
    texts: list[str] = Field(min_length=1)


class EmbeddingMetadataBase(BaseModel):
    source_type: str | None = None
    source_id: str | None = None
    content_hash: str = Field(min_length=1)
    provider: str = Field(min_length=1)
    model_name: str = Field(min_length=1)


class EmbeddingMetadataCreate(EmbeddingMetadataBase):
    id: str | None = None


class EmbeddingMetadataRead(EmbeddingMetadataCreate):
    id: str
    created_at: datetime

    model_config = ConfigDict(from_attributes=True)


class EmbeddingVectorResponse(BaseModel):
    vector: list[float]
    dimension: int
    provider: str
    model_name: str


class BatchEmbeddingVectorResponse(BaseModel):
    vectors: list[list[float]]
    dimension: int
    provider: str
    model_name: str
