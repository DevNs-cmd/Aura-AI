from __future__ import annotations

from collections.abc import Callable
from typing import Any

from pydantic import ValidationError

from .exceptions import VoiceConfigurationError, VoicePipelineError, VoiceProviderError, VoiceValidationError
from .repository import VoiceRepository, build_voice_repository
from .schemas import (
    VoiceSynthesisRequest,
    VoiceSynthesisResponse,
    VoiceTranscriptionRequest,
    VoiceTranscriptionResponse,
)
from .utils import (
    SUPPORTED_TRANSCRIPTION_FORMATS,
    SUPPORTED_SYNTHESIS_FORMATS,
    normalize_format,
    normalize_text,
    synthesis_format_to_mime_type,
    validate_audio_bytes,
    validate_mime_type,
)


class VoicePipeline:
    def __init__(
        self,
        *,
        repository_factory: Callable[[Any | None], VoiceRepository] | None = None,
    ) -> None:
        self._repository_factory = repository_factory or build_voice_repository

    def transcribe(
        self,
        request: VoiceTranscriptionRequest | dict[str, Any],
        db: Any | None = None,
    ) -> VoiceTranscriptionResponse:
        voice_request = self._ensure_transcription_request(request)
        repository = self._repository_factory(db)
        audio = validate_audio_bytes(voice_request.audio)
        mime_type = validate_mime_type(voice_request.mime_type)
        payload = self._call_repository_transcribe(repository, voice_request, audio, mime_type, db)

        return self._normalize_transcription_response(voice_request, payload, mime_type)

    def synthesize(
        self,
        request: VoiceSynthesisRequest | dict[str, Any],
        db: Any | None = None,
    ) -> VoiceSynthesisResponse:
        voice_request = self._ensure_synthesis_request(request)
        repository = self._repository_factory(db)
        output_format = normalize_format(
            voice_request.output_format,
            supported_formats=SUPPORTED_SYNTHESIS_FORMATS,
            field_name="output_format",
        )
        payload = self._call_repository_synthesize(repository, voice_request, output_format, db)

        return self._normalize_synthesis_response(voice_request, payload, output_format)

    @staticmethod
    def _ensure_transcription_request(
        request: VoiceTranscriptionRequest | dict[str, Any],
    ) -> VoiceTranscriptionRequest:
        if isinstance(request, VoiceTranscriptionRequest):
            return request
        try:
            return VoiceTranscriptionRequest.model_validate(request)
        except ValidationError as exc:
            raise VoiceValidationError("Invalid voice transcription request") from exc

    @staticmethod
    def _ensure_synthesis_request(
        request: VoiceSynthesisRequest | dict[str, Any],
    ) -> VoiceSynthesisRequest:
        if isinstance(request, VoiceSynthesisRequest):
            return request
        try:
            return VoiceSynthesisRequest.model_validate(request)
        except ValidationError as exc:
            raise VoiceValidationError("Invalid voice synthesis request") from exc

    def _call_repository_transcribe(
        self,
        repository: VoiceRepository,
        request: VoiceTranscriptionRequest,
        audio: bytes,
        mime_type: str,
        db: Any | None,
    ) -> Any:

        try:
            return repository.transcribe(
                audio=audio,
                mime_type=mime_type,
                language=request.language,
                model=request.model,
                output_format=request.output_format,
                prompt=request.prompt,
                temperature=request.temperature,
                metadata=request.metadata,
                db=db,
                )
        except VoiceProviderError:

            raise
        except Exception as exc:  # noqa: BLE001 - orchestration boundary
            raise VoicePipelineError("Failed to transcribe audio") from exc

    def _call_repository_synthesize(
        self,
        repository: VoiceRepository,
        request: VoiceSynthesisRequest,
        output_format: str,
        db: Any | None,
    ) -> Any:

        try:
            return repository.synthesize(
                text=request.text,
                language=request.language,
                voice=request.voice,
                model=request.model,
                output_format=output_format,
                speed=request.speed,
                metadata=request.metadata,
                db=db,
            )
        except VoiceProviderError:
            raise
        except Exception as exc:  # noqa: BLE001 - orchestration boundary
            raise VoicePipelineError("Failed to synthesize voice") from exc

    @staticmethod
    def _normalize_transcription_response(
        request: VoiceTranscriptionRequest,
        payload: Any,
        mime_type: str,
    ) -> VoiceTranscriptionResponse:
        if isinstance(payload, VoiceTranscriptionResponse):
            return payload
        if hasattr(payload, "model_dump"):
            payload = payload.model_dump()
        if isinstance(payload, dict):
            text = normalize_text(payload.get("text") or payload.get("transcript") or payload.get("content"))
            if text is None:
                raise VoiceProviderError("Voice transcription provider returned no text")
            model = normalize_text(payload.get("model")) or request.model
            provider = normalize_text(payload.get("provider")) or "unknown"
            language = normalize_text(payload.get("language")) or request.language
            output_format = normalize_format(
                payload.get("output_format") or request.output_format,
                supported_formats=SUPPORTED_TRANSCRIPTION_FORMATS,
                field_name="output_format",
            )
            return VoiceTranscriptionResponse(
                request=request,
                text=text,
                language=language,
                output_format=output_format,  # type: ignore[arg-type]
                provider=provider,
                model=model,
                raw_response=payload,
            )
        text = normalize_text(payload)
        if text is None:
            raise VoiceProviderError("Voice transcription provider returned an unsupported payload")
        return VoiceTranscriptionResponse(
            request=request,
            text=text,
            language=request.language,
            output_format=request.output_format,
            provider="unknown",
            model=request.model,
            raw_response={"text": text, "mime_type": mime_type},
        )

    @staticmethod
    def _normalize_synthesis_response(
        request: VoiceSynthesisRequest,
        payload: Any,
        output_format: str,
    ) -> VoiceSynthesisResponse:
        if isinstance(payload, VoiceSynthesisResponse):
            return payload
        if hasattr(payload, "model_dump"):
            payload = payload.model_dump()
        if isinstance(payload, dict):
            audio = payload.get("audio") or payload.get("data") or payload.get("content")
            if isinstance(audio, str):
                audio = audio.encode("utf-8")
            audio_bytes = validate_audio_bytes(audio)
            provider = normalize_text(payload.get("provider")) or "unknown"
            model = normalize_text(payload.get("model")) or request.model
            voice = normalize_text(payload.get("voice")) or request.voice
            mime_type = normalize_text(payload.get("mime_type")) or synthesis_format_to_mime_type(output_format)
            response_output_format = normalize_format(
                payload.get("output_format") or output_format,
                supported_formats=SUPPORTED_SYNTHESIS_FORMATS,
                field_name="output_format",
            )
            return VoiceSynthesisResponse(
                request=request,
                audio=audio_bytes,
                mime_type=mime_type,
                output_format=response_output_format,  # type: ignore[arg-type]
                provider=provider,
                model=model,
                voice=voice,
                raw_response=payload,
            )
        if isinstance(payload, (bytes, bytearray, memoryview)):
            audio_bytes = validate_audio_bytes(payload)
            return VoiceSynthesisResponse(
                request=request,
                audio=audio_bytes,
                mime_type=synthesis_format_to_mime_type(output_format),
                output_format=output_format,  # type: ignore[arg-type]
                provider="unknown",
                model=request.model,
                voice=request.voice,
                raw_response={"audio_size": len(audio_bytes)},
            )
        raise VoiceProviderError("Voice synthesis provider returned an unsupported payload")


def build_voice_pipeline(
    *,
    repository: VoiceRepository | None = None,
    stt_provider: Any | None = None,
    tts_provider: Any | None = None,
) -> VoicePipeline:
    if repository is None:
        if stt_provider is None or tts_provider is None:
            raise VoiceConfigurationError(
                "Speech-to-text and text-to-speech providers are required to build the voice pipeline"
            )
        repository = build_voice_repository(stt_provider=stt_provider, tts_provider=tts_provider)
    return VoicePipeline(repository_factory=lambda db: repository)
