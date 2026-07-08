from pathlib import Path
import base64
import sys

ROOT = Path(__file__).resolve().parents[3]
if str(ROOT) not in sys.path:
    sys.path.insert(0, str(ROOT))

import pytest

from app.ai.vision.exceptions import VisionProviderError, VisionValidationError
from app.ai.vision.pipeline import VisionPipeline
from app.ai.vision.repository import VisionRepository
from app.ai.vision.schemas import ImageDescriptionRequest, OCRRequest, VisionAnalysisRequest
from app.ai.vision.service import VisionService


PNG_BYTES = base64.b64decode(
    "iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAQAAAC1HAwCAAAAC0lEQVR42mP8/x8AAwMCAO7+9eUAAAAASUVORK5CYII="
)
PNG_B64 = base64.b64encode(PNG_BYTES).decode("ascii")


class EndToEndVisionProvider:
    provider_name = "end-to-end-vision"
    model_name = "vision-model"

    def __init__(self, *, fail_describe: bool = False) -> None:
        self.calls: list[tuple[str, dict[str, object]]] = []
        self.fail_describe = fail_describe

    def analyze_image(self, **kwargs):
        self.calls.append(("analyze_image", kwargs))
        return {
            "provider": self.provider_name,
            "model": kwargs.get("model") or self.model_name,
            "description": "a tiny PNG",
            "caption": "caption for png",
            "ocr_text": "hello from analyze",
            "object_detection": [{"label": "pixel", "confidence": 0.95}],
            "confidence": 0.96,
            "metadata": {"stage": "analyze"},
        }

    def extract_text(self, **kwargs):
        self.calls.append(("extract_text", kwargs))
        return {
            "provider": self.provider_name,
            "model": kwargs.get("model") or self.model_name,
            "text": "hello from OCR",
            "confidence": 0.88,
            "metadata": {"stage": "ocr"},
        }

    def describe_image(self, **kwargs):
        self.calls.append(("describe_image", kwargs))
        if self.fail_describe:
            raise RuntimeError("provider exploded")
        return {
            "provider": self.provider_name,
            "model": kwargs.get("model") or self.model_name,
            "description": "a small square image",
            "confidence": 0.92,
            "metadata": {"stage": "describe"},
        }


def test_vision_service_end_to_end_analysis_ocr_and_description():
    provider = EndToEndVisionProvider()
    repository = VisionRepository(provider=provider)
    pipeline = VisionPipeline(repository=repository)
    service = VisionService(pipeline=pipeline)

    analysis = service.analyze(
        VisionAnalysisRequest(
            image=PNG_B64,
            mime_type="image/png",
            model="vision-1",
            prompt="What is in this image?",
            metadata={"request": "analysis"},
        ),
        db="db-session",
    )

    ocr = service.extract_text(
        OCRRequest(
            image=memoryview(PNG_BYTES),
            mime_type="image/png",
            model="ocr-1",
            language_hint="en",
            metadata={"request": "ocr"},
        ),
        db="db-session",
    )

    description = service.describe(
        ImageDescriptionRequest(
            image=bytearray(PNG_BYTES),
            mime_type="image/png",
            model="describe-1",
            style="detailed",
            metadata={"request": "description"},
        ),
        db="db-session",
    )

    assert analysis.provider == "end-to-end-vision"
    assert analysis.description == "a tiny PNG"
    assert analysis.object_detection == [{"label": "pixel", "confidence": 0.95}]
    assert analysis.metadata == {"stage": "analyze"}

    assert ocr.text == "hello from OCR"
    assert ocr.metadata == {"stage": "ocr"}

    assert description.description == "a small square image"
    assert description.metadata == {"stage": "describe"}

    assert [call[0] for call in provider.calls] == ["analyze_image", "extract_text", "describe_image"]


def test_vision_service_rejects_invalid_requests():
    provider = EndToEndVisionProvider()
    service = VisionService(pipeline=VisionPipeline(repository=VisionRepository(provider=provider)))

    with pytest.raises(VisionValidationError):
        service.analyze({"image": b"", "mime_type": "image/png"})

    with pytest.raises(VisionValidationError):
        service.describe({"image": PNG_BYTES, "mime_type": "image/gif"})


def test_vision_service_wraps_pipeline_failures_as_provider_errors():
    provider = EndToEndVisionProvider(fail_describe=True)
    service = VisionService(pipeline=VisionPipeline(repository=VisionRepository(provider=provider)))

    with pytest.raises(VisionProviderError):
        service.describe(
            ImageDescriptionRequest(
                image=PNG_BYTES,
                mime_type="image/png",
            )
        )
