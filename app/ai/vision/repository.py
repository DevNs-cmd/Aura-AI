from __future__ import annotations

from typing import Any, Protocol

from .exceptions import VisionProviderError, VisionRepositoryError
from .utils import build_call_kwargs


class VisionProvider(Protocol):
    provider_name: str
    model_name: str

    def analyze_image(self, **kwargs: Any) -> Any:  # pragma: no cover - structural protocol
        ...

    def extract_text(self, **kwargs: Any) -> Any:  # pragma: no cover - structural protocol
        ...

    def describe_image(self, **kwargs: Any) -> Any:  # pragma: no cover - structural protocol
        ...


class VisionRepository:
    """Adapter boundary for the underlying vision provider."""

    def __init__(
        self,
        *,
        provider: VisionProvider | Any | None = None,
        db: Any | None = None,
    ) -> None:
        self._provider = provider
        self._db = db

    @property
    def db(self) -> Any | None:
        return self._db

    def analyze_image(self, **kwargs: Any) -> Any:
        return self._call_provider("analyze_image", kwargs)

    def extract_text(self, **kwargs: Any) -> Any:
        return self._call_provider("extract_text", kwargs)

    def describe_image(self, **kwargs: Any) -> Any:
        return self._call_provider("describe_image", kwargs)

    def _resolve_provider(self, method_name: str) -> Any:
        if self._provider is None:
            raise VisionRepositoryError(f"No vision provider configured for {method_name}")
        return self._provider

    def _call_provider(self, method_name: str, values: dict[str, Any]) -> Any:
        provider = self._resolve_provider(method_name)
        candidate = getattr(provider, method_name, None)
        if not callable(candidate) and callable(provider):
            candidate = provider
        if not callable(candidate):
            raise VisionRepositoryError(f"Vision provider does not expose {method_name}")

        kwargs = build_call_kwargs(candidate, values)
        try:
            return candidate(**kwargs) if kwargs else candidate()
        except VisionProviderError:
            raise
        except TypeError as exc:
            raise VisionRepositoryError(f"Failed to call vision provider method {method_name}") from exc
        except Exception as exc:  # noqa: BLE001 - adapter boundary
            raise VisionProviderError(f"Vision provider failed during {method_name}") from exc


def build_vision_repository(
    *,
    provider: VisionProvider | Any | None = None,
    db: Any | None = None,
) -> VisionRepository:
    return VisionRepository(provider=provider, db=db)
