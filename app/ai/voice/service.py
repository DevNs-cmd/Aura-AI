from __future__ import annotations

from typing import Any

from pydantic import ValidationError

from .exceptions import VoiceError, VoicePipelineError, VoiceValidationError
from .pipeline import VoicePipeline, build_voice_pipeline
from .schemas import (
    VoiceSynthesisRequest,
    VoiceSynthesisResponse,
    VoiceTranscriptionRequest,
    VoiceTranscriptionResponse,
)


class VoiceService:
    def __init__(self, *, pipeline: VoicePipeline) -> None:
        self._pipeline = pipeline

    def transcribe(
        self,
        request: VoiceTranscriptionRequest | dict[str, Any],
        db: Any | None = None,
    ) -> VoiceTranscriptionResponse:
        try:
            return self._pipeline.transcribe(request=request, db=db)
        except VoiceError:
            raise
        except ValidationError as exc:
            raise VoiceValidationError("Invalid voice transcription request") from exc
        except Exception as exc:  # noqa: BLE001 - service boundary
            raise VoicePipelineError("Failed to transcribe voice input") from exc

    def synthesize(
        self,
        request: VoiceSynthesisRequest | dict[str, Any],
        db: Any | None = None,
    ) -> VoiceSynthesisResponse:
        try:
            return self._pipeline.synthesize(request=request, db=db)
        except VoiceError:
            raise
        except ValidationError as exc:
            raise VoiceValidationError("Invalid voice synthesis request") from exc
        except Exception as exc:  # noqa: BLE001 - service boundary
            raise VoicePipelineError("Failed to synthesize voice") from exc


def build_voice_service(*, pipeline: VoicePipeline | None = None, **kwargs: Any) -> VoiceService:
    if pipeline is None:
        pipeline = build_voice_pipeline(**kwargs)
    return VoiceService(pipeline=pipeline)
