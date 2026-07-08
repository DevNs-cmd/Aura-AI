from __future__ import annotations

from typing import Any

from pydantic import BaseModel, ConfigDict, Field


class VisionAnalysisRequest(BaseModel):
    model_config = ConfigDict(extra="forbid", arbitrary_types_allowed=True)

    image: bytes | bytearray | memoryview | str
    mime_type: str = Field(min_length=1)
    model: str | None = Field(default=None, min_length=1)
    prompt: str | None = Field(default=None, min_length=1)
    metadata: dict[str, Any] = Field(default_factory=dict)


class OCRRequest(BaseModel):
    model_config = ConfigDict(extra="forbid", arbitrary_types_allowed=True)

    image: bytes | bytearray | memoryview | str
    mime_type: str = Field(min_length=1)
    model: str | None = Field(default=None, min_length=1)
    language_hint: str | None = Field(default=None, min_length=1)
    metadata: dict[str, Any] = Field(default_factory=dict)


class ImageDescriptionRequest(BaseModel):
    model_config = ConfigDict(extra="forbid", arbitrary_types_allowed=True)

    image: bytes | bytearray | memoryview | str
    mime_type: str = Field(min_length=1)
    model: str | None = Field(default=None, min_length=1)
    style: str | None = Field(default=None, min_length=1)
    metadata: dict[str, Any] = Field(default_factory=dict)


class VisionAnalysisResponse(BaseModel):
    model_config = ConfigDict(from_attributes=True)

    request: VisionAnalysisRequest
    provider: str = Field(min_length=1)
    model: str | None = Field(default=None, min_length=1)
    description: str | None = Field(default=None, min_length=1)
    caption: str | None = Field(default=None, min_length=1)
    ocr_text: str | None = Field(default=None, min_length=1)
    object_detection: dict[str, Any] | list[dict[str, Any]] | None = None
    confidence: float | None = Field(default=None, ge=0, le=1)
    metadata: dict[str, Any] = Field(default_factory=dict)
    raw_response: dict[str, Any] = Field(default_factory=dict)


class OCRResponse(BaseModel):
    model_config = ConfigDict(from_attributes=True)

    request: OCRRequest
    provider: str = Field(min_length=1)
    model: str | None = Field(default=None, min_length=1)
    text: str = Field(min_length=1)
    confidence: float | None = Field(default=None, ge=0, le=1)
    metadata: dict[str, Any] = Field(default_factory=dict)
    raw_response: dict[str, Any] = Field(default_factory=dict)


class ImageDescriptionResponse(BaseModel):
    model_config = ConfigDict(from_attributes=True)

    request: ImageDescriptionRequest
    provider: str = Field(min_length=1)
    model: str | None = Field(default=None, min_length=1)
    description: str = Field(min_length=1)
    confidence: float | None = Field(default=None, ge=0, le=1)
    metadata: dict[str, Any] = Field(default_factory=dict)
    raw_response: dict[str, Any] = Field(default_factory=dict)
