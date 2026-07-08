from __future__ import annotations

from collections.abc import Callable
from typing import Any

from pydantic import ValidationError

from .exceptions import (
    VisionConfigurationError,
    VisionPipelineError,
    VisionProviderError,
    VisionRepositoryError,
    VisionValidationError,
)
from .repository import VisionRepository, build_vision_repository
from .schemas import (
    ImageDescriptionRequest,
    ImageDescriptionResponse,
    OCRRequest,
    OCRResponse,
    VisionAnalysisRequest,
    VisionAnalysisResponse,
)
from .utils import (
    normalize_confidence,
    normalize_image_input,
    normalize_metadata,
    normalize_mime_type,
    normalize_text,
    payload_to_dict,
    validate_image_signature,
    validate_image_size,
)


class VisionPipeline:
    def __init__(
        self,
        *,
        repository: VisionRepository,
    ) -> None:
        self._repository = repository

    def analyze(
        self,
        request: VisionAnalysisRequest | dict[str, Any],
        db: Any | None = None,
    ) -> VisionAnalysisResponse:
        vision_request = self._ensure_analysis_request(request)
        image, mime_type = self._prepare_image(vision_request.image, vision_request.mime_type)
        payload = self._call_repository(
            "analyze_image",
            {
                "image": image,
                "mime_type": mime_type,
                "model": vision_request.model,
                "prompt": vision_request.prompt,
                "metadata": vision_request.metadata,
                "db": db,
            },
            error_message="Failed to analyze image",
        )
        return self._normalize_analysis_response(vision_request, payload)

    def extract_text(
        self,
        request: OCRRequest | dict[str, Any],
        db: Any | None = None,
    ) -> OCRResponse:
        ocr_request = self._ensure_ocr_request(request)
        image, mime_type = self._prepare_image(ocr_request.image, ocr_request.mime_type)
        payload = self._call_repository(
            "extract_text",
            {
                "image": image,
                "mime_type": mime_type,
                "model": ocr_request.model,
                "language_hint": ocr_request.language_hint,
                "metadata": ocr_request.metadata,
                "db": db,
            },
            error_message="Failed to extract text from image",
        )
        return self._normalize_ocr_response(ocr_request, payload)

    def describe(
        self,
        request: ImageDescriptionRequest | dict[str, Any],
        db: Any | None = None,
    ) -> ImageDescriptionResponse:
        describe_request = self._ensure_description_request(request)
        image, mime_type = self._prepare_image(describe_request.image, describe_request.mime_type)
        payload = self._call_repository(
            "describe_image",
            {
                "image": image,
                "mime_type": mime_type,
                "model": describe_request.model,
                "style": describe_request.style,
                "metadata": describe_request.metadata,
                "db": db,
            },
            error_message="Failed to describe image",
        )
        return self._normalize_description_response(describe_request, payload)

    @staticmethod
    def _ensure_analysis_request(request: VisionAnalysisRequest | dict[str, Any]) -> VisionAnalysisRequest:
        if isinstance(request, VisionAnalysisRequest):
            return request
        try:
            return VisionAnalysisRequest.model_validate(request)
        except ValidationError as exc:
            raise VisionValidationError("Invalid vision analysis request") from exc

    @staticmethod
    def _ensure_ocr_request(request: OCRRequest | dict[str, Any]) -> OCRRequest:
        if isinstance(request, OCRRequest):
            return request
        try:
            return OCRRequest.model_validate(request)
        except ValidationError as exc:
            raise VisionValidationError("Invalid OCR request") from exc

    @staticmethod
    def _ensure_description_request(
        request: ImageDescriptionRequest | dict[str, Any],
    ) -> ImageDescriptionRequest:
        if isinstance(request, ImageDescriptionRequest):
            return request
        try:
            return ImageDescriptionRequest.model_validate(request)
        except ValidationError as exc:
            raise VisionValidationError("Invalid image description request") from exc

    @staticmethod
    def _prepare_image(image: Any, mime_type: Any) -> tuple[bytes, str]:
        normalized_image = normalize_image_input(image)
        normalized_image = validate_image_size(normalized_image)
        normalized_mime_type = normalize_mime_type(mime_type)
        validate_image_signature(normalized_image, normalized_mime_type)
        return normalized_image, normalized_mime_type

    def _call_repository(self, method_name: str, values: dict[str, Any], *, error_message: str) -> Any:
        try:
            method = getattr(self._repository, method_name)
            return method(**values)
        except VisionValidationError:
            raise
        except (VisionRepositoryError, VisionProviderError) as exc:
            raise VisionPipelineError(error_message) from exc
        except Exception as exc:  # noqa: BLE001 - orchestration boundary
            raise VisionPipelineError(error_message) from exc

    @staticmethod
    def _normalize_analysis_response(
        request: VisionAnalysisRequest,
        payload: Any,
    ) -> VisionAnalysisResponse:
        if isinstance(payload, VisionAnalysisResponse):
            return payload
        payload_dict = payload_to_dict(payload)
        metadata = normalize_metadata(_first_non_none(payload_dict.get("metadata"), request.metadata))
        description = normalize_text(
            _first_non_none(
                payload_dict.get("description"),
                payload_dict.get("caption"),
                payload_dict.get("summary"),
                payload_dict.get("text"),
            )
        )
        caption = normalize_text(_first_non_none(payload_dict.get("caption"), payload_dict.get("description")))
        ocr_text = normalize_text(
            _first_non_none(
                payload_dict.get("ocr_text"),
                payload_dict.get("text"),
                payload_dict.get("content"),
                payload_dict.get("transcript"),
            )
        )
        object_detection = (
            _first_non_none(
                payload_dict.get("object_detection"),
                payload_dict.get("detections"),
                payload_dict.get("objects"),
                payload_dict.get("boxes"),
            )
        )
        confidence = normalize_confidence(_first_non_none(payload_dict.get("confidence"), payload_dict.get("score")))
        model = normalize_text(_first_non_none(payload_dict.get("model"), request.model))
        provider = normalize_text(payload_dict.get("provider")) or "unknown"
        return VisionAnalysisResponse(
            request=request,
            provider=provider,
            model=model,
            description=description,
            caption=caption,
            ocr_text=ocr_text,
            object_detection=object_detection,
            confidence=confidence,
            metadata=metadata,
            raw_response=payload_dict,
        )

    @staticmethod
    def _normalize_ocr_response(
        request: OCRRequest,
        payload: Any,
    ) -> OCRResponse:
        if isinstance(payload, OCRResponse):
            return payload
        payload_dict = payload_to_dict(payload)
        text = normalize_text(
            _first_non_none(
                payload_dict.get("text"),
                payload_dict.get("content"),
                payload_dict.get("ocr_text"),
            )
        )
        if text is None:
            raise VisionProviderError("OCR provider returned no text")
        metadata = normalize_metadata(_first_non_none(payload_dict.get("metadata"), request.metadata))
        confidence = normalize_confidence(_first_non_none(payload_dict.get("confidence"), payload_dict.get("score")))
        model = normalize_text(_first_non_none(payload_dict.get("model"), request.model))
        provider = normalize_text(payload_dict.get("provider")) or "unknown"
        return OCRResponse(
            request=request,
            provider=provider,
            model=model,
            text=text,
            confidence=confidence,
            metadata=metadata,
            raw_response=payload_dict,
        )

    @staticmethod
    def _normalize_description_response(
        request: ImageDescriptionRequest,
        payload: Any,
    ) -> ImageDescriptionResponse:
        if isinstance(payload, ImageDescriptionResponse):
            return payload
        payload_dict = payload_to_dict(payload)
        description = normalize_text(
            _first_non_none(
                payload_dict.get("description"),
                payload_dict.get("caption"),
                payload_dict.get("summary"),
                payload_dict.get("text"),
            )
        )
        if description is None:
            raise VisionProviderError("Description provider returned no description")
        metadata = normalize_metadata(_first_non_none(payload_dict.get("metadata"), request.metadata))
        confidence = normalize_confidence(_first_non_none(payload_dict.get("confidence"), payload_dict.get("score")))
        model = normalize_text(_first_non_none(payload_dict.get("model"), request.model))
        provider = normalize_text(payload_dict.get("provider")) or "unknown"
        return ImageDescriptionResponse(
            request=request,
            provider=provider,
            model=model,
            description=description,
            confidence=confidence,
            metadata=metadata,
            raw_response=payload_dict,
        )


def _first_non_none(*values: Any) -> Any:
    for value in values:
        if value is not None:
            return value
    return None


def build_vision_pipeline(
    *,
    repository: VisionRepository | None = None,
    provider: Any | None = None,
) -> VisionPipeline:
    if repository is None:
        if provider is None:
            raise VisionConfigurationError("A vision repository or provider is required")
        repository = build_vision_repository(provider=provider)
    return VisionPipeline(repository=repository)
