from __future__ import annotations

import inspect
from typing import Any

from .exceptions import VoiceAudioValidationError, VoiceValidationError

SUPPORTED_AUDIO_MIME_TYPES = {
    "audio/aac",
    "audio/flac",
    "audio/mp4",
    "audio/mpeg",
    "audio/ogg",
    "audio/wav",
    "audio/webm",
    "audio/x-m4a",
    "audio/x-wav",
    "audio/wave",
}

SUPPORTED_TRANSCRIPTION_FORMATS = {"text", "json", "srt", "vtt"}
SUPPORTED_SYNTHESIS_FORMATS = {"mp3", "wav", "ogg", "flac", "pcm"}

MIME_TYPE_TO_EXTENSION = {
    "audio/aac": "aac",
    "audio/flac": "flac",
    "audio/mp4": "m4a",
    "audio/mpeg": "mp3",
    "audio/ogg": "ogg",
    "audio/wav": "wav",
    "audio/webm": "webm",
    "audio/x-m4a": "m4a",
    "audio/x-wav": "wav",
    "audio/wave": "wav",
}

SYNTHESIS_FORMAT_TO_MIME_TYPE = {
    "flac": "audio/flac",
    "mp3": "audio/mpeg",
    "ogg": "audio/ogg",
    "pcm": "audio/L16",
    "wav": "audio/wav",
}


def normalize_text(value: Any) -> str | None:
    if value is None:
        return None
    text = str(value).strip()
    return text or None


def normalize_format(value: Any, *, supported_formats: set[str], field_name: str) -> str:
    normalized = normalize_text(value)
    if normalized is None:
        raise VoiceValidationError(f"{field_name} is required")
    lowered = normalized.lower()
    if lowered not in supported_formats:
        raise VoiceValidationError(f"Unsupported {field_name}: {normalized}")
    return lowered


def validate_audio_bytes(audio: Any) -> bytes:
    if isinstance(audio, memoryview):
        audio = audio.tobytes()
    if not isinstance(audio, (bytes, bytearray)):
        raise VoiceAudioValidationError("Audio payload must be raw bytes")
    payload = bytes(audio)
    if not payload:
        raise VoiceAudioValidationError("Audio payload cannot be empty")
    return payload


def validate_mime_type(mime_type: Any) -> str:
    normalized = normalize_text(mime_type)
    if normalized is None:
        raise VoiceAudioValidationError("Audio mime type is required")
    lowered = normalized.lower()
    if lowered not in SUPPORTED_AUDIO_MIME_TYPES:
        raise VoiceAudioValidationError(f"Unsupported audio mime type: {normalized}")
    return lowered


def mime_type_to_extension(mime_type: str) -> str:
    return MIME_TYPE_TO_EXTENSION.get(mime_type, "bin")


def synthesis_format_to_mime_type(output_format: str) -> str:
    return SYNTHESIS_FORMAT_TO_MIME_TYPE.get(output_format, f"audio/{output_format}")


def build_call_kwargs(callable_obj: Any, values: dict[str, Any]) -> dict[str, Any]:
    try:
        signature = inspect.signature(callable_obj)
    except (TypeError, ValueError):
        return {}

    if any(parameter.kind == inspect.Parameter.VAR_KEYWORD for parameter in signature.parameters.values()):
        return dict(values)

    kwargs: dict[str, Any] = {}
    for name, parameter in signature.parameters.items():
        if parameter.kind not in (
            inspect.Parameter.POSITIONAL_OR_KEYWORD,
            inspect.Parameter.KEYWORD_ONLY,
        ):
            continue
        if name in values:
            kwargs[name] = values[name]
    return kwargs
