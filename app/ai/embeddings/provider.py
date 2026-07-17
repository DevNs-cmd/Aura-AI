from __future__ import annotations

import hashlib
import math
import re
from typing import Any, Protocol, Sequence
from unicodedata import normalize as unicodedata_normalize

import requests

from app.ai.embeddings.exceptions import (
    EmbeddingConfigurationError,
    EmbeddingProviderError,
    EmbeddingValidationError,
)
from app.core.config import settings

WHITESPACE_RE = re.compile(r"\s+")


class EmbeddingProvider(Protocol):
    provider_name: str
    model_name: str
    dimension: int | None

    def generate_embedding(self, text: str) -> list[float]:
        ...

    def generate_batch_embeddings(self, texts: Sequence[str]) -> list[list[float]]:
        ...


def _ensure_text(text: str) -> str:
    if not isinstance(text, str):
        raise EmbeddingValidationError("Text must be a string")

    normalized = WHITESPACE_RE.sub(" ", unicodedata_normalize("NFKC", text)).strip()
    if not normalized:
        raise EmbeddingValidationError("Text cannot be empty")
    return normalized


def _ensure_texts(texts: Sequence[str]) -> list[str]:
    if isinstance(texts, (str, bytes)):
        raise EmbeddingValidationError("Batch input must be a sequence of strings")

    cleaned = [_ensure_text(text) for text in list(texts)]
    if not cleaned:
        raise EmbeddingValidationError("At least one text is required")
    return cleaned


class DeterministicEmbeddingProvider:
    """Test-only provider that produces stable vectors from text."""

    def __init__(self, *, model_name: str, dimension: int = 64):
        if dimension <= 0:
            raise EmbeddingConfigurationError("Embedding dimension must be positive")

        self.provider_name = "deterministic"
        self.model_name = model_name
        self.dimension = dimension

    def _vectorize(self, text: str) -> list[float]:
        tokens = re.findall(r"[A-Za-z0-9_']+", text.lower())
        vector = [0.0] * self.dimension

        if not tokens:
            return vector

        for position, token in enumerate(tokens):
            digest = hashlib.sha256(f"{position}:{token}".encode("utf-8")).digest()
            for offset in range(0, len(digest), 4):
                index = digest[offset] % self.dimension
                sign = 1.0 if digest[offset + 1] % 2 == 0 else -1.0
                magnitude = 0.5 + (digest[offset + 2] / 255.0) * 0.5
                vector[index] += sign * magnitude

        norm = math.sqrt(sum(value * value for value in vector))
        if norm == 0:
            return vector
        return [value / norm for value in vector]

    def generate_embedding(self, text: str) -> list[float]:
        return self._vectorize(_ensure_text(text))

    def generate_batch_embeddings(self, texts: Sequence[str]) -> list[list[float]]:
        return [self.generate_embedding(text) for text in _ensure_texts(texts)]


class HttpEmbeddingProvider:
    """OpenAI-compatible HTTP embedding provider adapter."""

    def __init__(
        self,
        *,
        api_url: str,
        api_key: str,
        model_name: str,
        timeout_seconds: int = 30,
    ):
        if not api_url:
            raise EmbeddingConfigurationError("Embedding API URL is required")
        if not model_name:
            raise EmbeddingConfigurationError("Embedding model name is required")

        self.provider_name = "http"
        self.model_name = model_name
        self.api_url = api_url.rstrip("/")
        self.api_key = api_key
        self.timeout_seconds = timeout_seconds
        self.dimension = None

    def _headers(self) -> dict[str, str]:
        headers = {"Content-Type": "application/json"}
        if self.api_key:
            headers["Authorization"] = f"Bearer {self.api_key}"
        return headers

    def _post(self, payload: dict[str, Any]) -> dict[str, Any]:
        try:
            response = requests.post(
                self.api_url,
                headers=self._headers(),
                json=payload,
                timeout=self.timeout_seconds,
            )
            response.raise_for_status()
            data = response.json()
            if not isinstance(data, dict):
                raise ValueError("Embedding response must be a JSON object")
            return data
        except requests.RequestException as exc:
            raise EmbeddingProviderError("Embedding request failed") from exc
        except ValueError as exc:
            raise EmbeddingProviderError("Embedding provider returned invalid JSON") from exc

    @staticmethod
    def _extract_vectors(data: dict[str, Any], batch_size: int) -> list[list[float]]:
        if "data" in data and isinstance(data["data"], list):
            vectors: list[list[float]] = []
            for item in data["data"]:
                if isinstance(item, dict) and "embedding" in item and isinstance(item["embedding"], list):
                    vectors.append([float(value) for value in item["embedding"]])
            if vectors:
                if len(vectors) != batch_size:
                    raise EmbeddingProviderError("Embedding provider returned an unexpected batch size")
                return vectors

        if "embedding" in data and isinstance(data["embedding"], list):
            return [[float(value) for value in data["embedding"]]]

        raise EmbeddingProviderError("Embedding provider response did not include vectors")

    def generate_embedding(self, text: str) -> list[float]:
        payload = {"model": self.model_name, "input": _ensure_text(text)}
        data = self._post(payload)
        vectors = self._extract_vectors(data, batch_size=1)
        vector = vectors[0]
        self.dimension = len(vector)
        return vector

    def generate_batch_embeddings(self, texts: Sequence[str]) -> list[list[float]]:
        cleaned_texts = _ensure_texts(texts)
        payload = {"model": self.model_name, "input": cleaned_texts}
        data = self._post(payload)
        vectors = self._extract_vectors(data, batch_size=len(cleaned_texts))
        if len(vectors) != len(cleaned_texts):
            raise EmbeddingProviderError("Embedding provider returned an unexpected batch size")
        self.dimension = len(vectors[0]) if vectors else self.dimension
        return vectors


def build_embedding_provider() -> EmbeddingProvider:
    provider_type = (settings.EMBEDDING_PROVIDER or "http").strip().lower()

    if provider_type in {"http", "remote", "openai_compatible"}:
        return HttpEmbeddingProvider(
            api_url=settings.EMBEDDING_API_URL,
            api_key=settings.EMBEDDING_API_KEY,
            model_name=settings.EMBEDDING_MODEL,
            timeout_seconds=settings.EMBEDDING_TIMEOUT_SECONDS,
        )

    if provider_type == "deterministic":
        return DeterministicEmbeddingProvider(
            model_name=settings.EMBEDDING_MODEL,
            dimension=settings.EMBEDDING_DIMENSION,
        )

    raise EmbeddingConfigurationError(f"Unsupported embedding provider: {settings.EMBEDDING_PROVIDER}")
