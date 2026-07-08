from __future__ import annotations

from typing import Any, Protocol

from .exceptions import VoiceRepositoryError
from .utils import build_call_kwargs


class SpeechToTextProvider(Protocol):
    def transcribe(self, **kwargs: Any) -> Any:  # pragma: no cover - structural protocol
        ...


class TextToSpeechProvider(Protocol):
    def synthesize(self, **kwargs: Any) -> Any:  # pragma: no cover - structural protocol
        ...


class VoiceRepository:
    """Provider adapter for voice transcription and synthesis."""

    def __init__(
        self,
        *,
        stt_provider: SpeechToTextProvider | Any | None = None,
        tts_provider: TextToSpeechProvider | Any | None = None,
        db: Any | None = None,
    ) -> None:
        self._stt_provider = stt_provider
        self._tts_provider = tts_provider
        self._db = db

    @property
    def db(self) -> Any | None:
        return self._db

    def transcribe(self, **kwargs: Any) -> Any:
        provider = self._resolve_provider(self._stt_provider, "transcribe")
        return self._call_provider(provider, "transcribe", kwargs)

    def synthesize(self, **kwargs: Any) -> Any:
        provider = self._resolve_provider(self._tts_provider, "synthesize")
        return self._call_provider(provider, "synthesize", kwargs)

    def _resolve_provider(self, provider: Any | None, default_method: str) -> Any:
        if provider is None:
            raise VoiceRepositoryError(f"No voice provider configured for {default_method}")
        return provider

    def _call_provider(self, provider: Any, method_name: str, values: dict[str, Any]) -> Any:
        candidate = getattr(provider, method_name, None)
        if not callable(candidate) and callable(provider):
            candidate = provider
        if not callable(candidate):
            raise VoiceRepositoryError(f"Voice provider does not expose {method_name}")

        kwargs = build_call_kwargs(candidate, values)
        try:
            return candidate(**kwargs) if kwargs else candidate()
        except TypeError as exc:
            raise VoiceRepositoryError(f"Failed to call voice provider method {method_name}") from exc


def build_voice_repository(
    *,
    stt_provider: SpeechToTextProvider | Any | None = None,
    tts_provider: TextToSpeechProvider | Any | None = None,
    db: Any | None = None,
) -> VoiceRepository:
    return VoiceRepository(stt_provider=stt_provider, tts_provider=tts_provider, db=db)
