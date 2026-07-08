from __future__ import annotations

from typing import Any

from pydantic import ValidationError

from .exceptions import VisionConfigurationError, VisionError, VisionPipelineError, VisionProviderError, VisionValidationError
from .pipeline import VisionPipeline, build_vision_pipeline
from .schemas import ImageDescriptionRequest, ImageDescriptionResponse, OCRRequest, OCRResponse, VisionAnalysisRequest, VisionAnalysisResponse


class VisionService:
    def __init__(self, *, pipeline: VisionPipeline) -> None:
        self._pipeline = pipeline

    def analyze(
        self,
        request: VisionAnalysisRequest | dict[str, Any],
        db: Any | None = None,
    ) -> VisionAnalysisResponse:
        try:
            return self._pipeline.analyze(request, db=db)
        except VisionValidationError:
            raise
        except VisionConfigurationError:
            raise
        except VisionError as exc:
            raise VisionProviderError("Failed to analyze image") from exc
        except ValidationError as exc:
            raise VisionValidationError("Invalid vision analysis request") from exc
        except Exception as exc:  # noqa: BLE001 - service boundary
            raise VisionProviderError("Failed to analyze image") from exc

    def extract_text(
        self,
        request: OCRRequest | dict[str, Any],
        db: Any | None = None,
    ) -> OCRResponse:
        try:
            return self._pipeline.extract_text(request, db=db)
        except VisionValidationError:
            raise
        except VisionConfigurationError:
            raise
        except VisionError as exc:
            raise VisionProviderError("Failed to extract text from image") from exc
        except ValidationError as exc:
            raise VisionValidationError("Invalid OCR request") from exc
        except Exception as exc:  # noqa: BLE001 - service boundary
            raise VisionProviderError("Failed to extract text from image") from exc

    def describe(
        self,
        request: ImageDescriptionRequest | dict[str, Any],
        db: Any | None = None,
    ) -> ImageDescriptionResponse:
        try:
            return self._pipeline.describe(request, db=db)
        except VisionValidationError:
            raise
        except VisionConfigurationError:
            raise
        except VisionError as exc:
            raise VisionProviderError("Failed to describe image") from exc
        except ValidationError as exc:
            raise VisionValidationError("Invalid image description request") from exc
        except Exception as exc:  # noqa: BLE001 - service boundary
            raise VisionProviderError("Failed to describe image") from exc


def build_vision_service(*, pipeline: VisionPipeline | None = None, provider: Any | None = None) -> VisionService:
    if pipeline is None:
        pipeline = build_vision_pipeline(provider=provider)
    return VisionService(pipeline=pipeline)
