from __future__ import annotations

from typing import Any, Sequence

from app.ai.embeddings.exceptions import EmbeddingConfigurationError, VectorStoreError
from app.ai.vectorstore import VectorStoreSearchResult, VectorStoreSearchResultWithScore


class ChromaVectorStore:

    def __init__(
        self,
        *,
        collection_name: str,
        persist_directory: str | None = None,
        client: Any | None = None,
    ):
        if not collection_name:
            raise EmbeddingConfigurationError("Chroma collection name is required")

        self.collection_name = collection_name

        if client is not None:
            self._client = client
        else:
            try:
                import chromadb
            except ImportError as exc:  # pragma: no cover - optional dependency guard
                raise EmbeddingConfigurationError("chromadb is required for the Chroma vector store adapter") from exc

            if persist_directory:
                self._client = chromadb.PersistentClient(path=persist_directory)
            else:
                self._client = chromadb.EphemeralClient()

        self._collection = self._client.get_or_create_collection(
            name=collection_name,
            metadata={"hnsw:space": "cosine"},
        )

    def upsert(self, *, embedding_id: str, vector: Sequence[float], metadata: dict[str, Any]) -> None:
        try:
            self._collection.upsert(
                ids=[embedding_id],
                embeddings=[[float(value) for value in vector]],
                metadatas=[dict(metadata)],
            )
        except Exception as exc:  # pragma: no cover - defensive adapter boundary
            raise VectorStoreError("Failed to upsert embedding into ChromaDB") from exc

    def upsert_batch(self, items: Sequence[tuple[str, Sequence[float], dict[str, Any]]]) -> None:
        try:
            self._collection.upsert(
                ids=[embedding_id for embedding_id, _, _ in items],
                embeddings=[[float(value) for value in vector] for _, vector, _ in items],
                metadatas=[dict(metadata) for _, _, metadata in items],
            )
        except Exception as exc:  # pragma: no cover - defensive adapter boundary
            raise VectorStoreError("Failed to upsert embedding batch into ChromaDB") from exc

    def delete(self, embedding_id: str) -> None:
        try:
            self._collection.delete(ids=[embedding_id])
        except Exception as exc:  # pragma: no cover - defensive adapter boundary
            raise VectorStoreError("Failed to delete embedding from ChromaDB") from exc

    def similarity_search(
        self,
        *,
        query_vector: Sequence[float],
        top_k: int,
        filters: dict[str, Any] | None = None,
    ) -> list[VectorStoreSearchResult]:
        results_with_scores = self.similarity_search_with_scores(
            query_vector=query_vector,
            top_k=top_k,
            filters=filters,
        )
        return [
            VectorStoreSearchResult(embedding_id=r.embedding_id, metadata=r.metadata)
            for r in results_with_scores
        ]

    def similarity_search_with_scores(
        self,
        *,
        query_vector: Sequence[float],
        top_k: int,
        filters: dict[str, Any] | None = None,
    ) -> list[VectorStoreSearchResultWithScore]:
        if top_k <= 0:
            return []

        if filters and len(filters) > 1:
            where = {"$and": [{k: v} for k, v in filters.items()]}
        else:
            where = filters or None

        try:
            # Chroma supports where-filtering via the `where` kwarg.
            query_result = self._collection.query(
                query_embeddings=[list(float(v) for v in query_vector)],
                n_results=top_k,
                where=where,
                include=["metadatas", "distances"],
            )

            ids_batch = query_result.get("ids", [[]])[0]
            metas_batch = query_result.get("metadatas", [[]])[0]
            distances_batch = query_result.get("distances", [[]])[0]

            # Chroma distances for cosine space are treated as *distance* (lower = closer).
            out: list[VectorStoreSearchResultWithScore] = []
            for i, embedding_id in enumerate(ids_batch):
                metadata = metas_batch[i] if i < len(metas_batch) and metas_batch[i] is not None else {}
                # Only expose the numeric distance here; architecture calls this field `score` but
                # semantics are distance for now because collection is configured with cosine.
                distance = float(distances_batch[i]) if i < len(distances_batch) and distances_batch[i] is not None else 0.0
                out.append(
                    VectorStoreSearchResultWithScore(
                        embedding_id=str(embedding_id),
                        metadata=dict(metadata),
                        score=distance,
                    )
                )

            return out

        except Exception as exc:  # pragma: no cover - defensive adapter boundary
            raise VectorStoreError("Failed to run similarity search in ChromaDB") from exc

