from __future__ import annotations

from uuid import UUID

from app.ai.embeddings.pipeline import EmbeddingPipeline
from app.ai.memory.exceptions import MemoryConfigurationError, MemoryRetrievalError
from app.ai.memory.schemas import MemoryCreate, MemoryRead, MemoryRetrievalResult, MemoryUpdate
from app.ai.memory.service import MemoryService


class MemoryPipeline:
    def __init__(
        self,
        *,
        service: MemoryService,
        embedding_pipeline: EmbeddingPipeline | None = None,
    ):
        self.service = service
        self.embedding_pipeline = embedding_pipeline

    def _require_embedding_pipeline(self) -> EmbeddingPipeline:
        if self.embedding_pipeline is None:
            raise MemoryConfigurationError("Embedding pipeline is required for memory indexing")
        return self.embedding_pipeline

    @staticmethod
    def _index_text(memory: MemoryRead) -> str:
        return f"{memory.key}: {memory.value}"

    def create_memory(self, payload: MemoryCreate) -> MemoryRead:
        memory = self.service.create_memory(payload)

        try:
            pipeline = self._require_embedding_pipeline()
            pipeline.generate_embedding(
                self._index_text(memory),
                persist=True,
                source_type="memory",
                source_id=str(memory.id),
                metadata={
                    "memory_id": str(memory.id),
                    "user_id": str(memory.user_id),
                    "key": memory.key,
                    "value": memory.value,
                    "source": memory.source,
                },
            )
        except Exception as exc:
            try:
                self.service.delete_memory(memory.id)
            except Exception:
                pass
            raise MemoryRetrievalError("Failed to index newly created memory") from exc

        return memory

    def update_memory(self, memory_id: UUID, payload: MemoryUpdate) -> MemoryRead:
        previous = self.service.get_memory(memory_id)
        memory = self.service.update_memory(memory_id, payload)

        try:
            pipeline = self._require_embedding_pipeline()
            pipeline.generate_embedding(
                self._index_text(memory),
                persist=True,
                source_type="memory",
                source_id=str(memory.id),
                metadata={
                    "memory_id": str(memory.id),
                    "user_id": str(memory.user_id),
                    "key": memory.key,
                    "value": memory.value,
                    "source": memory.source,
                },
            )
        except Exception as exc:
            try:
                self.service.update_memory(
                    previous.id,
                    MemoryUpdate(key=previous.key, value=previous.value, source=previous.source),
                )
            except Exception:
                pass
            raise MemoryRetrievalError("Failed to reindex updated memory") from exc

        return memory

    def delete_memory(self, memory_id: UUID) -> None:
        self.service.delete_memory(memory_id)

    def get_memory(self, memory_id: UUID) -> MemoryRead:
        return self.service.get_memory(memory_id)

    def list_memories(self, user_id: UUID, *, limit: int | None = None) -> list[MemoryRead]:
        return self.service.list_memories(user_id, limit=limit)

    def retrieve_memories(
        self,
        query: str,
        *,
        user_id: UUID,
        top_k: int = 5,
        source: str | None = None,
        metadata_filters: dict[str, object] | None = None,
    ) -> list[MemoryRetrievalResult]:
        return self.service.retrieve_memories(
            query,
            user_id=user_id,
            top_k=top_k,
            source=source,
            metadata_filters=metadata_filters,
        )


def build_memory_pipeline(
    *,
    service: MemoryService | None = None,
    embedding_pipeline: EmbeddingPipeline | None = None,
) -> MemoryPipeline:
    if service is None:
        raise MemoryConfigurationError("A memory service is required to build the memory pipeline")
    if embedding_pipeline is None:
        raise MemoryConfigurationError("An embedding pipeline is required to build the memory pipeline")

    return MemoryPipeline(
        service=service,
        embedding_pipeline=embedding_pipeline,
    )
