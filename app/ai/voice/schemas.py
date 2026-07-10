from __future__ import annotations

from typing import Any, Literal

from pydantic import BaseModel, ConfigDict, Field


VoiceTranscriptionFormat = Literal["text", "json", "srt", "vtt"]
VoiceSynthesisFormat = Literal["mp3", "wav", "ogg", "flac", "pcm"]


class VoiceTranscriptionRequest(BaseModel):
    audio: bytes = Field(min_length=1)
    mime_type: str = Field(min_length=1)
    language: str | None = Field(default=None, min_length=1)
    model: str | None = Field(default=None, min_length=1)
    output_format: VoiceTranscriptionFormat = "text"
    prompt: str | None = Field(default=None, min_length=1)
    temperature: float | None = Field(default=None, ge=0, le=2)
    metadata: dict[str, Any] = Field(default_factory=dict)


class VoiceTranscriptionResponse(BaseModel):
    model_config = ConfigDict(from_attributes=True)

    request: VoiceTranscriptionRequest
    text: str = Field(min_length=1)
    language: str | None = Field(default=None, min_length=1)
    output_format: VoiceTranscriptionFormat = "text"
    provider: str = Field(min_length=1)
    model: str | None = Field(default=None, min_length=1)
    raw_response: dict[str, Any] = Field(default_factory=dict)


class VoiceSynthesisRequest(BaseModel):
    text: str = Field(min_length=1)
    language: str | None = Field(default=None, min_length=1)
    voice: str | None = Field(default=None, min_length=1)
    model: str | None = Field(default=None, min_length=1)
    output_format: VoiceSynthesisFormat = "mp3"
    speed: float | None = Field(default=None, gt=0)
    metadata: dict[str, Any] = Field(default_factory=dict)


class VoiceSynthesisResponse(BaseModel):
    model_config = ConfigDict(from_attributes=True)

    request: VoiceSynthesisRequest
    audio: bytes = Field(min_length=1)
    mime_type: str = Field(min_length=1)
    output_format: VoiceSynthesisFormat = "mp3"
    provider: str = Field(min_length=1)
    model: str | None = Field(default=None, min_length=1)
    voice: str | None = Field(default=None, min_length=1)
    raw_response: dict[str, Any] = Field(default_factory=dict)
