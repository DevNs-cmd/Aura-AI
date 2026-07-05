from __future__ import annotations

from typing import Sequence

from app.ai.embeddings.exceptions import EmbeddingProviderError
from app.ai.embeddings.provider import EmbeddingProvider, _ensure_text, _ensure_texts, build_embedding_provider


def normalize_text(text: str) -> str:
    return _ensure_text(text)


class EmbeddingService:
    def __init__(self, provider: EmbeddingProvider):
        self.provider = provider

    def generate_embedding(self, text: str) -> list[float]:
        normalized = _ensure_text(text)
        try:
            vector = self.provider.generate_embedding(normalized)
        except EmbeddingProviderError:
            raise
        except Exception as exc:  # pragma: no cover - defensive adapter boundary
            raise EmbeddingProviderError("Unexpected failure while generating embedding") from exc

        if not vector:
            raise EmbeddingProviderError("Embedding provider returned an empty vector")
        return [float(value) for value in vector]

    def generate_batch_embeddings(self, texts: Sequence[str]) -> list[list[float]]:
        normalized_texts = _ensure_texts(texts)
        try:
            vectors = self.provider.generate_batch_embeddings(normalized_texts)
        except EmbeddingProviderError:
            raise
        except Exception as exc:  # pragma: no cover - defensive adapter boundary
            raise EmbeddingProviderError("Unexpected failure while generating batch embeddings") from exc

        if len(vectors) != len(normalized_texts):
            raise EmbeddingProviderError("Batch embedding count did not match input size")
        if any(not vector for vector in vectors):
            raise EmbeddingProviderError("Embedding provider returned an empty vector in batch response")

        first_dimension = len(vectors[0])
        if any(len(vector) != first_dimension for vector in vectors):
            raise EmbeddingProviderError("Embedding provider returned inconsistent vector dimensions")
        return [[float(value) for value in vector] for vector in vectors]


def build_embedding_service(provider: EmbeddingProvider | None = None) -> EmbeddingService:
    return EmbeddingService(provider=provider or build_embedding_provider())
