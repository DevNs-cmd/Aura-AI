from __future__ import annotations

import uuid
from typing import Any, Sequence

from app.ai.embeddings.exceptions import EmbeddingValidationError
from app.ai.embeddings.service import EmbeddingService, normalize_text
from app.ai.vectorstore import VectorStore, build_vector_store
from app.repositories.embedding_repository import EmbeddingRepository, _hash_text
from app.schemas.embedding import EmbeddingMetadataCreate


class EmbeddingPipeline:
    def __init__(
        self,
        service: EmbeddingService,
        vector_store: VectorStore | None = None,
        repository: EmbeddingRepository | None = None,
    ):
        self.service = service
        self.vector_store = vector_store
        self.repository = repository

    def preprocess_text(self, text: str) -> str:
        normalized = normalize_text(text)
        if not normalized:
            raise EmbeddingValidationError("Text cannot be empty")
        return normalized

    def preprocess_texts(self, texts: Sequence[str]) -> list[str]:
        if isinstance(texts, (str, bytes)):
            raise EmbeddingValidationError("Batch input must be a sequence of strings")

        cleaned = [self.preprocess_text(text) for text in list(texts)]
        if not cleaned:
            raise EmbeddingValidationError("At least one text is required")
        return cleaned

    def _build_metadata(
        self,
        *,
        embedding_id: str,
        normalized_text: str,
        source_type: str | None,
        source_id: str | None,
        provider: str,
        model_name: str,
    ) -> EmbeddingMetadataCreate:
        return EmbeddingMetadataCreate(
            id=embedding_id,
            source_type=source_type,
            source_id=source_id,
            content_hash=_hash_text(normalized_text),
            provider=provider,
            model_name=model_name,
        )

    def _require_persistence_dependencies(self) -> tuple[VectorStore, EmbeddingRepository]:
        if self.vector_store is None:
            raise EmbeddingValidationError("Vector store is required when persist=True")
        if self.repository is None:
            raise EmbeddingValidationError("Repository is required when persist=True")
        return self.vector_store, self.repository

    def generate_embedding(
        self,
        text: str,
        *,
        persist: bool = False,
        source_type: str | None = None,
        source_id: str | None = None,
        metadata: dict[str, Any] | None = None,
    ) -> list[float]:
        normalized = self.preprocess_text(text)
        vector = self.service.generate_embedding(normalized)

        if persist:
            vector_store, repository = self._require_persistence_dependencies()
            embedding_id = str(uuid.uuid4())
            payload = self._build_metadata(
                embedding_id=embedding_id,
                normalized_text=normalized,
                source_type=source_type,
                source_id=source_id,
                provider=self.service.provider.provider_name,
                model_name=self.service.provider.model_name,
            )
            vector_store.upsert(
                embedding_id=embedding_id,
                vector=vector,
                metadata={
                    **(metadata or {}),
                    **payload.model_dump(mode="json", exclude_none=True),
                },
            )
            try:
                repository.save(payload)
            except Exception:
                try:
                    vector_store.delete(embedding_id)
                except Exception:
                    pass
                raise

        return vector

    def generate_batch_embeddings(
        self,
        texts: Sequence[str],
        *,
        persist: bool = False,
        source_type: str | None = None,
        source_id: str | None = None,
        metadata: dict[str, Any] | None = None,
    ) -> list[list[float]]:
        normalized_texts = self.preprocess_texts(list(texts))
        vectors = self.service.generate_batch_embeddings(normalized_texts)

        if persist:
            vector_store, repository = self._require_persistence_dependencies()
            payloads: list[EmbeddingMetadataCreate] = []
            vector_items: list[tuple[str, Sequence[float], dict[str, Any]]] = []

            for normalized_text, vector in zip(normalized_texts, vectors, strict=True):
                embedding_id = str(uuid.uuid4())
                payload = self._build_metadata(
                    embedding_id=embedding_id,
                    normalized_text=normalized_text,
                    source_type=source_type,
                    source_id=source_id,
                    provider=self.service.provider.provider_name,
                    model_name=self.service.provider.model_name,
                )
                payloads.append(payload)
                vector_items.append(
                    (
                        embedding_id,
                        vector,
                        {
                            **(metadata or {}),
                            **payload.model_dump(mode="json", exclude_none=True),
                        },
                    )
                )

            vector_store.upsert_batch(vector_items)
            try:
                repository.save_batch(payloads)
            except Exception:
                for embedding_id, _, _ in vector_items:
                    try:
                        vector_store.delete(embedding_id)
                    except Exception:
                        pass
                raise

        return vectors


def build_embedding_pipeline(
    *,
    service: EmbeddingService | None = None,
    vector_store: VectorStore | None = None,
    repository: EmbeddingRepository | None = None,
) -> EmbeddingPipeline:
    from app.ai.embeddings.service import build_embedding_service

    return EmbeddingPipeline(
        service=service or build_embedding_service(),
        vector_store=vector_store or build_vector_store(),
        repository=repository,
    )
