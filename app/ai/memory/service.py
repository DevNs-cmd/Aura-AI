from __future__ import annotations

import json
from typing import Any, Sequence
from uuid import UUID

from app.ai.embeddings.provider import _ensure_text
from app.ai.embeddings.service import EmbeddingService
from app.ai.memory.cache import MemoryCache, dumps_memory_reads, dumps_memory_retrieval_results, loads_memory_reads, loads_memory_retrieval_results
from app.ai.memory.exceptions import (
    MemoryConfigurationError,
    MemoryNotFoundError,
    MemoryRetrievalError,
    MemoryValidationError,
)
from app.ai.memory.ranking import MemoryRanker, MemoryScoredCandidate, build_memory_ranker
from app.ai.memory.repository import MemoryRepository
from app.ai.memory.schemas import MemoryCreate, MemoryRead, MemoryRetrievalResult, MemoryUpdate
from app.ai.vectorstore import VectorStore, VectorStoreSearchResultWithScore


class MemoryService:
    def __init__(
        self,
        *,
        repository: MemoryRepository,
        cache: MemoryCache | None = None,
        embedding_service: EmbeddingService | None = None,
        vector_store: VectorStore | None = None,
        ranker: MemoryRanker | None = None,
    ):
        self.repository = repository
        self.cache = cache
        self.embedding_service = embedding_service
        self.vector_store = vector_store
        self.ranker = ranker or build_memory_ranker()

    @staticmethod
    def _memory_key(memory_id: UUID) -> str:
        return f"memory:item:{memory_id}"

    @staticmethod
    def _user_version_key(user_id: UUID) -> str:
        return f"memory:user:{user_id}:version"

    @staticmethod
    def _user_list_key(user_id: UUID, version: int, limit: int | None) -> str:
        return f"memory:user:{user_id}:list:v{version}:limit:{limit if limit is not None else 'all'}"

    @staticmethod
    def _search_key(
        user_id: UUID,
        version: int,
        query: str,
        top_k: int,
        source: str | None,
        metadata_signature: str,
    ) -> str:
        return (
            f"memory:user:{user_id}:search:v{version}:top_k:{top_k}:source:{source or 'any'}:"
            f"query:{query.lower()}|filters:{metadata_signature}"
        )

    @staticmethod
    def _normalized_filters(metadata_filters: dict[str, Any] | None) -> str:
        if not metadata_filters:
            return "{}"
        return json.dumps(metadata_filters, sort_keys=True, default=str)

    def _normalize_payload(self, payload: MemoryCreate | MemoryUpdate) -> MemoryCreate | MemoryUpdate:
        if isinstance(payload, MemoryCreate):
            return MemoryCreate(
                user_id=payload.user_id,
                key=_ensure_text(payload.key),
                value=_ensure_text(payload.value),
                source=_ensure_text(payload.source),
            )
        return MemoryUpdate(
            key=_ensure_text(payload.key) if payload.key is not None else None,
            value=_ensure_text(payload.value) if payload.value is not None else None,
            source=_ensure_text(payload.source) if payload.source is not None else None,
        )

    def _require_retrieval_dependencies(self) -> tuple[EmbeddingService, VectorStore]:
        if self.embedding_service is None:
            raise MemoryConfigurationError("Embedding service is required for memory retrieval")
        if self.vector_store is None:
            raise MemoryConfigurationError("Vector store is required for memory retrieval")
        return self.embedding_service, self.vector_store

    def _get_user_version(self, user_id: UUID) -> int:
        if self.cache is None:
            return 0

        cached = self.cache.get(self._user_version_key(user_id))
        if cached is None:
            return 0
        try:
            return int(cached)
        except ValueError as exc:  # pragma: no cover - defensive cache boundary
            raise MemoryRetrievalError("Invalid user cache version") from exc

    def _bump_user_version(self, user_id: UUID) -> int:
        if self.cache is None:
            return 0
        return self.cache.increment(self._user_version_key(user_id))

    def _cache_memory(self, memory: MemoryRead) -> None:
        if self.cache is None:
            return
        self.cache.set(self._memory_key(memory.id), memory.model_dump_json())

    def _get_cached_memory(self, memory_id: UUID) -> MemoryRead | None:
        if self.cache is None:
            return None
        cached = self.cache.get(self._memory_key(memory_id))
        if cached is None:
            return None
        return MemoryRead.model_validate_json(cached)

    def _cache_user_memories(self, user_id: UUID, limit: int | None, memories: Sequence[MemoryRead]) -> None:
        if self.cache is None:
            return
        version = self._get_user_version(user_id)
        self.cache.set(self._user_list_key(user_id, version, limit), dumps_memory_reads(list(memories)))

    def _get_cached_user_memories(self, user_id: UUID, limit: int | None) -> list[MemoryRead] | None:
        if self.cache is None:
            return None
        version = self._get_user_version(user_id)
        cached = self.cache.get(self._user_list_key(user_id, version, limit))
        if cached is None:
            return None
        return loads_memory_reads(cached)

    def _cache_search_results(
        self,
        user_id: UUID,
        query: str,
        top_k: int,
        source: str | None,
        metadata_filters: dict[str, Any] | None,
        results: Sequence[MemoryRetrievalResult],
    ) -> None:
        if self.cache is None:
            return
        version = self._get_user_version(user_id)
        self.cache.set(
            self._search_key(
                user_id,
                version,
                query,
                top_k,
                source,
                self._normalized_filters(metadata_filters),
            ),
            dumps_memory_retrieval_results(list(results)),
        )

    def _get_cached_search_results(
        self,
        user_id: UUID,
        query: str,
        top_k: int,
        source: str | None,
        metadata_filters: dict[str, Any] | None,
    ) -> list[MemoryRetrievalResult] | None:
        if self.cache is None:
            return None
        version = self._get_user_version(user_id)
        cached = self.cache.get(
            self._search_key(
                user_id,
                version,
                query,
                top_k,
                source,
                self._normalized_filters(metadata_filters),
            )
        )
        if cached is None:
            return None
        return loads_memory_retrieval_results(cached)

    @staticmethod
    def _read_memory(memory) -> MemoryRead:
        return MemoryRead.model_validate(memory, from_attributes=True)

    def create_memory(self, payload: MemoryCreate) -> MemoryRead:
        normalized = self._normalize_payload(payload)
        if not isinstance(normalized, MemoryCreate):
            raise MemoryValidationError("Create payload normalization failed")

        record = self.repository.create(normalized)
        memory = self._read_memory(record)
        self._cache_memory(memory)
        self._bump_user_version(memory.user_id)
        return memory

    def update_memory(self, memory_id: UUID, payload: MemoryUpdate) -> MemoryRead:
        normalized = self._normalize_payload(payload)
        if not isinstance(normalized, MemoryUpdate):
            raise MemoryValidationError("Update payload normalization failed")

        record = self.repository.update(memory_id, normalized)
        memory = self._read_memory(record)
        self._cache_memory(memory)
        self._bump_user_version(memory.user_id)
        return memory

    def delete_memory(self, memory_id: UUID) -> None:
        existing = self.repository.get_by_id(memory_id)
        if existing is None:
            raise MemoryNotFoundError(f"Memory {memory_id} was not found")

        self.repository.delete(memory_id)
        if self.cache is not None:
            self.cache.delete(self._memory_key(memory_id))
        self._bump_user_version(existing.user_id)

    def get_memory(self, memory_id: UUID) -> MemoryRead:
        cached = self._get_cached_memory(memory_id)
        if cached is not None:
            return cached

        record = self.repository.get_by_id(memory_id)
        if record is None:
            raise MemoryNotFoundError(f"Memory {memory_id} was not found")

        memory = self._read_memory(record)
        self._cache_memory(memory)
        return memory

    def list_memories(self, user_id: UUID, *, limit: int | None = None) -> list[MemoryRead]:
        cached = self._get_cached_user_memories(user_id, limit)
        if cached is not None:
            return cached

        records = self.repository.list_by_user(user_id, limit=limit)
        memories = [self._read_memory(record) for record in records]
        self._cache_user_memories(user_id, limit, memories)
        return memories

    def retrieve_memories(
        self,
        query: str,
        *,
        user_id: UUID,
        top_k: int = 5,
        source: str | None = None,
        metadata_filters: dict[str, Any] | None = None,
    ) -> list[MemoryRetrievalResult]:
        normalized_query = _ensure_text(query)
        if top_k <= 0:
            raise MemoryValidationError("top_k must be positive")

        cached = self._get_cached_search_results(user_id, normalized_query, top_k, source, metadata_filters)
        if cached is not None:
            return cached

        try:
            embedding_service, vector_store = self._require_retrieval_dependencies()
            query_vector = embedding_service.generate_embedding(normalized_query)

            filters: dict[str, Any] = {"source_type": "memory", "user_id": str(user_id)}
            if source is not None:
                filters["source"] = source
            if metadata_filters:
                filters.update(metadata_filters)

            vector_results = vector_store.similarity_search_with_scores(
                query_vector=query_vector,
                top_k=max(top_k * 4, top_k),
                filters=filters,
            )

            candidates: list[MemoryScoredCandidate] = []
            for result in vector_results:
                memory_id = self._extract_memory_id(result)
                if memory_id is None:
                    continue

                memory = self._get_cached_memory(memory_id)
                if memory is None:
                    record = self.repository.get_by_id(memory_id)
                    if record is None:
                        continue
                    memory = self._read_memory(record)
                    self._cache_memory(memory)

                if str(memory.user_id) != str(user_id):
                    continue
                if source is not None and memory.source != source:
                    continue

                candidates.append(MemoryScoredCandidate(memory=memory, vector_distance=result.score))

            ranked = self.ranker.rank(normalized_query, candidates)[:top_k]
            self._cache_search_results(user_id, normalized_query, top_k, source, metadata_filters, ranked)
            return ranked
        except MemoryValidationError:
            raise
        except MemoryRetrievalError:
            raise
        except Exception as exc:  # pragma: no cover - adapter boundary
            raise MemoryRetrievalError("Failed to retrieve memories") from exc

    @staticmethod
    def _extract_memory_id(result: VectorStoreSearchResultWithScore) -> UUID | None:
        memory_id = result.metadata.get("source_id")
        if memory_id is None:
            memory_id = result.metadata.get("memory_id")
        if memory_id is None:
            return None
        try:
            return UUID(str(memory_id))
        except (TypeError, ValueError):
            return None


def build_memory_service(
    *,
    repository: MemoryRepository | None = None,
    cache: MemoryCache | None = None,
    embedding_service: EmbeddingService | None = None,
    vector_store: VectorStore | None = None,
    ranker: MemoryRanker | None = None,
) -> MemoryService:
    if repository is None:
        raise MemoryConfigurationError("A memory repository is required to build the memory service")

    return MemoryService(
        repository=repository,
        cache=cache,
        embedding_service=embedding_service,
        vector_store=vector_store,
        ranker=ranker or build_memory_ranker(),
    )
