from pathlib import Path
import sys

ROOT = Path(__file__).resolve().parents[3]
if str(ROOT) not in sys.path:
    sys.path.insert(0, str(ROOT))

from app.ai.voice.pipeline import VoicePipeline
from app.ai.voice.schemas import VoiceSynthesisRequest, VoiceTranscriptionRequest
from app.ai.voice.service import VoiceService


class EndToEndRepository:
    def __init__(self) -> None:
        self.calls = []

    def transcribe(self, **kwargs):
        self.calls.append(("transcribe", kwargs))
        return "transcribed-text" if kwargs.get("output_format") == "text" else {
            "provider": "e2e-stt",
            "model": "stt-model",
            "text": "transcribed text",
            "language": kwargs.get("language") or "en",
            "output_format": kwargs.get("output_format") or "text",
        }

    def synthesize(self, **kwargs):
        self.calls.append(("synthesize", kwargs))
        return {
            "provider": "e2e-tts",
            "model": "tts-model",
            "audio": b"FAKEAUDIO",
            "mime_type": "audio/mpeg",
            "voice": kwargs.get("voice") or "alloy",
            "output_format": kwargs.get("output_format") or "mp3",
        }


def test_voice_service_end_to_end_transcription_and_synthesis():
    repository = EndToEndRepository()
    pipeline = VoicePipeline(repository_factory=lambda db: repository)
    service = VoiceService(pipeline=pipeline)

    transcription = service.transcribe(
        VoiceTranscriptionRequest(
            audio=b"fake-audio-bytes",
            mime_type="audio/wav",
            language="en",
            output_format="text",
        ),
        db="db-session",
    )

    synthesis = service.synthesize(
        VoiceSynthesisRequest(
            text=transcription.text,
            language="en",
            voice="alloy",
            output_format="mp3",
        ),
        db="db-session",
    )

    assert transcription.text == "transcribed-text"
    assert repository.calls[0][0] == "transcribe"
    assert synthesis.audio == b"FAKEAUDIO"
    assert synthesis.mime_type == "audio/mpeg"
    assert repository.calls[1][0] == "synthesize"
