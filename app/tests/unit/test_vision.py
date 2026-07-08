from pathlib import Path
import base64
import sys

ROOT = Path(__file__).resolve().parents[3]
if str(ROOT) not in sys.path:
    sys.path.insert(0, str(ROOT))

import pytest
from pydantic import ValidationError

from app.ai.vision.exceptions import VisionPipelineError, VisionProviderError, VisionRepositoryError, VisionValidationError
from app.ai.vision.pipeline import VisionPipeline
from app.ai.vision.repository import VisionRepository
from app.ai.vision.schemas import ImageDescriptionRequest, OCRRequest, VisionAnalysisRequest
from app.ai.vision.utils import normalize_mime_type, normalize_text, validate_image_signature


PNG_BYTES = base64.b64decode(
    "iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAQAAAC1HAwCAAAAC0lEQVR42mP8/x8AAwMCAO7+9eUAAAAASUVORK5CYII="
)
PNG_B64 = base64.b64encode(PNG_BYTES).decode("ascii")


class FakeVisionProvider:
    provider_name = "fake-vision"
    model_name = "fake-model"

    def __init__(self) -> None:
        self.calls: list[tuple[str, dict[str, object]]] = []

    def analyze_image(self, **kwargs):
        self.calls.append(("analyze_image", kwargs))
        return {
            "provider": self.provider_name,
            "model": kwargs.get("model") or self.model_name,
            "description": "a small test image",
            "caption": "test caption",
            "ocr_text": "hello vision",
            "object_detection": [{"label": "square", "confidence": 0.88}],
            "confidence": 0.91,
            "metadata": {"provider": "analysis"},
        }

    def extract_text(self, **kwargs):
        self.calls.append(("extract_text", kwargs))
        return {
            "provider": self.provider_name,
            "model": kwargs.get("model") or self.model_name,
            "text": "hello vision",
            "confidence": 0.83,
            "metadata": {"provider": "ocr"},
        }

    def describe_image(self, **kwargs):
        self.calls.append(("describe_image", kwargs))
        return {
            "provider": self.provider_name,
            "model": kwargs.get("model") or self.model_name,
            "description": "a small test image",
            "confidence": 0.77,
            "metadata": {"provider": "description"},
        }


class FailingVisionProvider:
    def analyze_image(self, **kwargs):
        raise RuntimeError("boom")


class FakeRepository:
    def __init__(self) -> None:
        self.calls: list[tuple[str, dict[str, object]]] = []

    def analyze_image(self, **kwargs):
        self.calls.append(("analyze_image", kwargs))
        return {
            "provider": "fake-provider",
            "model": kwargs.get("model") or "fake-model",
            "description": "analyzed",
            "caption": "captioned",
            "ocr_text": "detected text",
            "detections": [{"label": "object", "confidence": 0.5}],
            "confidence": 0.9,
            "metadata": {"source": "repo"},
        }

    def extract_text(self, **kwargs):
        self.calls.append(("extract_text", kwargs))
        return {
            "provider": "fake-provider",
            "model": kwargs.get("model") or "fake-model",
            "text": "ocr text",
            "confidence": 0.8,
            "metadata": {"source": "repo"},
        }

    def describe_image(self, **kwargs):
        self.calls.append(("describe_image", kwargs))
        return {
            "provider": "fake-provider",
            "model": kwargs.get("model") or "fake-model",
            "description": "detailed description",
            "confidence": 0.7,
            "metadata": {"source": "repo"},
        }


def test_utils_normalize_mime_and_image_signature():
    assert normalize_mime_type("IMAGE/PNG") == "image/png"
    assert normalize_text("  hello  ") == "hello"
    assert validate_image_signature(PNG_BYTES, "image/png") == PNG_BYTES


def test_repository_invokes_injected_provider_methods():
    provider = FakeVisionProvider()
    repository = VisionRepository(provider=provider)

    repository.analyze_image(image=PNG_BYTES, mime_type="image/png", model="vision-a", prompt="describe")
    repository.extract_text(image=PNG_BYTES, mime_type="image/png", language_hint="en")
    repository.describe_image(image=PNG_BYTES, mime_type="image/png", style="detailed")

    assert [call[0] for call in provider.calls] == ["analyze_image", "extract_text", "describe_image"]
    assert provider.calls[0][1]["model"] == "vision-a"
    assert provider.calls[1][1]["language_hint"] == "en"
    assert provider.calls[2][1]["style"] == "detailed"


def test_repository_missing_provider_raises_repository_error():
    repository = VisionRepository(provider=None)

    with pytest.raises(VisionRepositoryError):
        repository.analyze_image(image=PNG_BYTES, mime_type="image/png")


def test_repository_provider_failure_raises_provider_error():
    repository = VisionRepository(provider=FailingVisionProvider())

    with pytest.raises(VisionProviderError):
        repository.analyze_image(image=PNG_BYTES, mime_type="image/png")


def test_pipeline_analyze_normalizes_base64_input_and_response():
    repository = FakeRepository()
    pipeline = VisionPipeline(repository=repository)
    request = VisionAnalysisRequest(
        image=PNG_B64,
        mime_type="image/png",
        model="vision-1",
        prompt="Describe this image",
        metadata={"request": "analysis"},
    )

    response = pipeline.analyze(request, db="db-session")

    assert repository.calls[0][0] == "analyze_image"
    assert repository.calls[0][1]["image"] == PNG_BYTES
    assert repository.calls[0][1]["mime_type"] == "image/png"
    assert response.provider == "fake-provider"
    assert response.model == "vision-1"
    assert response.description == "analyzed"
    assert response.caption == "captioned"
    assert response.ocr_text == "detected text"
    assert response.object_detection == [{"label": "object", "confidence": 0.5}]
    assert response.confidence == 0.9
    assert response.metadata == {"source": "repo"}


def test_pipeline_extract_text_validates_and_normalizes_payload():
    repository = FakeRepository()
    pipeline = VisionPipeline(repository=repository)
    request = OCRRequest(
        image=memoryview(PNG_BYTES),
        mime_type="image/png",
        model="ocr-1",
        language_hint="en",
        metadata={"request": "ocr"},
    )

    response = pipeline.extract_text(request)

    assert repository.calls[0][0] == "extract_text"
    assert repository.calls[0][1]["image"] == PNG_BYTES
    assert response.text == "ocr text"
    assert response.provider == "fake-provider"
    assert response.confidence == 0.8
    assert response.metadata == {"source": "repo"}


def test_pipeline_describe_accepts_bytearray_input():
    repository = FakeRepository()
    pipeline = VisionPipeline(repository=repository)
    request = ImageDescriptionRequest(
        image=bytearray(PNG_BYTES),
        mime_type="image/png",
        style="detailed",
    )

    response = pipeline.describe(request)

    assert repository.calls[0][0] == "describe_image"
    assert response.description == "detailed description"
    assert response.provider == "fake-provider"


def test_pipeline_rejects_invalid_image_inputs():
    repository = FakeRepository()
    pipeline = VisionPipeline(repository=repository)

    with pytest.raises(VisionValidationError):
        pipeline.analyze({"image": PNG_BYTES, "mime_type": "image/gif"})

    with pytest.raises(VisionValidationError):
        pipeline.analyze({"image": b"", "mime_type": "image/png"})

    with pytest.raises(VisionValidationError):
        pipeline.analyze({"image": "not-base64", "mime_type": "image/png"})


def test_pipeline_wraps_repository_failures():
    class BrokenRepository:
        def analyze_image(self, **kwargs):
            raise VisionRepositoryError("broken repository")

    pipeline = VisionPipeline(repository=BrokenRepository())

    with pytest.raises(VisionPipelineError):
        pipeline.analyze({"image": PNG_BYTES, "mime_type": "image/png"})


def test_schema_validation_rejects_extra_fields():
    with pytest.raises(ValidationError):
        VisionAnalysisRequest.model_validate(
            {
                "image": PNG_BYTES,
                "mime_type": "image/png",
                "unexpected": True,
            }
        )
