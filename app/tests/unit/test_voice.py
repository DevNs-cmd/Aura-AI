from pathlib import Path
import sys

ROOT = Path(__file__).resolve().parents[3]
if str(ROOT) not in sys.path:
    sys.path.insert(0, str(ROOT))

import pytest

from app.ai.voice.exceptions import VoiceAudioValidationError
from app.ai.voice.pipeline import VoicePipeline
from app.ai.voice.schemas import (
    VoiceSynthesisRequest,
    VoiceSynthesisResponse,
    VoiceTranscriptionRequest,
    VoiceTranscriptionResponse,
)
from app.ai.voice.service import VoiceService
from app.ai.voice.utils import validate_audio_bytes, validate_mime_type


class FakeRepository:
    def __init__(self) -> None:
        self.calls = []

    def transcribe(self, **kwargs):
        self.calls.append(("transcribe", kwargs))
        return {
            "provider": "fake-stt",
            "model": kwargs.get("model") or "fake-stt-model",
            "text": "hello world",
            "language": kwargs.get("language") or "en",
            "output_format": kwargs.get("output_format") or "text",
        }

    def synthesize(self, **kwargs):
        self.calls.append(("synthesize", kwargs))
        return {
            "provider": "fake-tts",
            "model": kwargs.get("model") or "fake-tts-model",
            "audio": b"RIFF....",
            "mime_type": "audio/wav",
            "voice": kwargs.get("voice") or "default",
            "output_format": kwargs.get("output_format") or "wav",
        }


class FakePipeline:
    def __init__(self) -> None:
        self.calls = []

    def transcribe(self, request, db=None):
        self.calls.append(("transcribe", request, db))
        return VoiceTranscriptionResponse(
            request=request,
            text="hello world",
            language="en",
            output_format="text",
            provider="fake-stt",
            model="fake-stt-model",
        )

    def synthesize(self, request, db=None):
        self.calls.append(("synthesize", request, db))
        return VoiceSynthesisResponse(
            request=request,
            audio=b"RIFF....",
            mime_type="audio/wav",
            output_format="wav",
            provider="fake-tts",
            model="fake-tts-model",
            voice="alloy",
        )


def test_voice_service_delegates_to_pipeline():
    pipeline = FakePipeline()
    service = VoiceService(pipeline=pipeline)
    request = VoiceTranscriptionRequest(audio=b"abc123", mime_type="audio/wav")

    response = service.transcribe(request, db="db-session")

    assert pipeline.calls[0][0] == "transcribe"
    assert pipeline.calls[0][1] == request
    assert pipeline.calls[0][2] == "db-session"
    assert response.text == "hello world"


def test_voice_pipeline_transcribe_validates_and_normalizes_payload():
    repository = FakeRepository()
    pipeline = VoicePipeline(repository_factory=lambda db: repository)
    request = VoiceTranscriptionRequest(
        audio=b"audio-bytes",
        mime_type="audio/wav",
        language="en",
        model="fake-stt-model",
        output_format="json",
        prompt="Please transcribe clearly",
    )

    response = pipeline.transcribe(request, db="db-session")

    assert repository.calls[0][0] == "transcribe"
    assert repository.calls[0][1]["mime_type"] == "audio/wav"
    assert repository.calls[0][1]["language"] == "en"
    assert response.text == "hello world"
    assert response.output_format == "json"
    assert response.provider == "fake-stt"


def test_voice_pipeline_synthesize_normalizes_binary_payload():
    repository = FakeRepository()
    pipeline = VoicePipeline(repository_factory=lambda db: repository)
    request = VoiceSynthesisRequest(
        text="Say hello",
        language="en",
        voice="alloy",
        model="fake-tts-model",
        output_format="wav",
    )

    response = pipeline.synthesize(request, db="db-session")

    assert repository.calls[0][0] == "synthesize"
    assert repository.calls[0][1]["voice"] == "alloy"
    assert response.audio == b"RIFF...."
    assert response.mime_type == "audio/wav"
    assert response.output_format == "wav"


def test_voice_utils_validate_audio_and_mime_type():
    assert validate_audio_bytes(memoryview(b"abc")) == b"abc"
    assert validate_mime_type("audio/WAV") == "audio/wav"

    with pytest.raises(VoiceAudioValidationError):
        validate_audio_bytes(b"")
