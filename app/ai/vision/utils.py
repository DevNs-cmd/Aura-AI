from __future__ import annotations

import base64
import binascii
import inspect
import math
import re
from typing import Any

from .exceptions import VisionValidationError

SUPPORTED_IMAGE_MIME_TYPES = {
    "image/jpeg",
    "image/png",
    "image/webp",
}

MIME_TYPE_ALIASES = {
    "image/jpg": "image/jpeg",
    "image/pjpeg": "image/jpeg",
    "image/x-png": "image/png",
    "image/x-webp": "image/webp",
}

MAX_IMAGE_BYTES = 10 * 1024 * 1024
WHITESPACE_RE = re.compile(r"\s+")


def normalize_text(value: Any) -> str | None:
    if value is None:
        return None
    text = str(value).strip()
    return text or None


def normalize_mime_type(value: Any) -> str:
    normalized = normalize_text(value)
    if normalized is None:
        raise VisionValidationError("mime_type is required")
    lowered = normalized.lower()
    lowered = MIME_TYPE_ALIASES.get(lowered, lowered)
    if lowered not in SUPPORTED_IMAGE_MIME_TYPES:
        raise VisionValidationError(f"Unsupported image mime type: {normalized}")
    return lowered


def normalize_confidence(value: Any) -> float | None:
    if value is None:
        return None
    if isinstance(value, bool):
        raise VisionValidationError("confidence must be numeric")
    try:
        confidence = float(value)
    except (TypeError, ValueError) as exc:
        raise VisionValidationError("confidence must be numeric") from exc
    if not math.isfinite(confidence):
        raise VisionValidationError("confidence must be finite")
    if confidence < 0 or confidence > 1:
        raise VisionValidationError("confidence must be between 0 and 1")
    return confidence


def _decode_base64_image(value: str) -> bytes:
    cleaned = WHITESPACE_RE.sub("", value.strip())
    if cleaned.startswith("data:"):
        try:
            _, cleaned = cleaned.split(",", 1)
        except ValueError as exc:
            raise VisionValidationError("Invalid data URI image payload") from exc
    try:
        return base64.b64decode(cleaned, validate=True)
    except (ValueError, binascii.Error) as exc:
        raise VisionValidationError("Image string must be valid base64") from exc


def normalize_image_input(image: Any) -> bytes:
    if isinstance(image, memoryview):
        image = image.tobytes()
    elif isinstance(image, bytearray):
        image = bytes(image)
    elif isinstance(image, str):
        image = _decode_base64_image(image)
    if not isinstance(image, bytes):
        raise VisionValidationError("Image must be bytes-like or base64 encoded text")
    if not image:
        raise VisionValidationError("Image payload cannot be empty")
    return image


def validate_image_size(image: bytes, *, max_bytes: int = MAX_IMAGE_BYTES) -> bytes:
    if len(image) > max_bytes:
        raise VisionValidationError(f"Image payload exceeds {max_bytes} bytes")
    return image


def detect_image_mime_type(image: bytes) -> str | None:
    if image.startswith(b"\x89PNG\r\n\x1a\n"):
        return "image/png"
    if image.startswith(b"\xff\xd8\xff"):
        return "image/jpeg"
    if len(image) >= 12 and image.startswith(b"RIFF") and image[8:12] == b"WEBP":
        return "image/webp"
    return None


def validate_image_signature(image: bytes, mime_type: str) -> bytes:
    detected = detect_image_mime_type(image)
    if detected is None:
        raise VisionValidationError("Unsupported or unrecognized image data")
    if detected != mime_type:
        raise VisionValidationError(f"Image data does not match declared mime type: {mime_type}")
    return image


def payload_to_dict(payload: Any) -> dict[str, Any]:
    if isinstance(payload, dict):
        return dict(payload)
    if hasattr(payload, "model_dump"):
        dumped = payload.model_dump()
        if isinstance(dumped, dict):
            return dumped
    return {"response": payload}


def normalize_metadata(metadata: Any) -> dict[str, Any]:
    if metadata is None:
        return {}
    if isinstance(metadata, dict):
        return dict(metadata)
    if hasattr(metadata, "model_dump"):
        dumped = metadata.model_dump()
        if isinstance(dumped, dict):
            return dumped
    raise VisionValidationError("metadata must be a mapping")


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
