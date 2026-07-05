from __future__ import annotations

from dataclasses import dataclass
from typing import Any, Protocol, Sequence


@dataclass(frozen=True)
class VectorStoreSearchResult:
    embedding_id: str
    metadata: dict[str, Any]


@dataclass(frozen=True)
class VectorStoreSearchResultWithScore(VectorStoreSearchResult):
    score: float


class VectorStore(Protocol):
    def upsert(self, *, embedding_id: str, vector: Sequence[float], metadata: dict[str, Any]) -> None:
        ...

    def upsert_batch(
        self,
        items: Sequence[tuple[str, Sequence[float], dict[str, Any]]],
    ) -> None:
        ...

    def delete(self, embedding_id: str) -> None:
        ...

    def similarity_search(
        self,
        *,
        query_vector: Sequence[float],
        top_k: int,
        filters: dict[str, Any] | None = None,
    ) -> list[VectorStoreSearchResult]:
        ...

    def similarity_search_with_scores(
        self,
        *,
        query_vector: Sequence[float],
        top_k: int,
        filters: dict[str, Any] | None = None,
    ) -> list[VectorStoreSearchResultWithScore]:
        ...


def build_vector_store() -> VectorStore:
    from app.ai.vectorstore.chroma import ChromaVectorStore
    from app.core.config import settings

    return ChromaVectorStore(
        collection_name=settings.CHROMA_COLLECTION_NAME,
        persist_directory=settings.CHROMA_PERSIST_DIRECTORY,
    )



from app.ai.vectorstore.chroma import ChromaVectorStore  # noqa: E402

__all__ = ["ChromaVectorStore", "VectorStore", "build_vector_store"]
