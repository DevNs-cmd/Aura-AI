from __future__ import annotations

from types import SimpleNamespace

import pytest

from app.ai.vectorstore import VectorStoreSearchResult, VectorStoreSearchResultWithScore
from app.ai.vectorstore.chroma import ChromaVectorStore


class FakeCollection:
    def __init__(self):
        self.last_query_kwargs = None

    def upsert(self, **kwargs):
        raise NotImplementedError

    def delete(self, **kwargs):
        raise NotImplementedError

    def query(self, **kwargs):
        self.last_query_kwargs = kwargs

        # Shape matches Chroma: lists are batched by query_embeddings.
        return {
            "ids": [["id-1", "id-2"]],
            "metadatas": [[{"k": "v1"}, {"k": "v2"}]],
            "distances": [[0.12, 0.34]],
        }


class FakeClient:
    def get_or_create_collection(self, name: str, metadata: dict):
        return FakeCollection()


def _build_store():
    # Use injected fake client so we don't need chromadb in unit tests.
    return ChromaVectorStore(collection_name="test", client=FakeClient())


def test_similarity_search_returns_typed_results_and_metadata():
    store = _build_store()

    results = store.similarity_search(query_vector=[0.0, 1.0], top_k=2)

    assert isinstance(results[0], VectorStoreSearchResult)
    assert results[0].embedding_id == "id-1"
    assert results[0].metadata == {"k": "v1"}
    assert results[1].embedding_id == "id-2"


def test_similarity_search_with_scores_passes_where_filters_and_returns_scores():
    store = _build_store()

    results = store.similarity_search_with_scores(
        query_vector=[0.0, 1.0],
        top_k=2,
        filters={"source_type": "document"},
    )

    assert isinstance(results[0], VectorStoreSearchResultWithScore)
    assert results[0].embedding_id == "id-1"
    assert results[0].score == 0.12
    assert results[1].score == 0.34

    # Validate that filters were propagated to Chroma `where`.
    collection: FakeCollection = store._collection  # type: ignore[attr-defined]
    assert collection.last_query_kwargs["where"] == {"source_type": "document"}
    assert collection.last_query_kwargs["n_results"] == 2
    assert collection.last_query_kwargs["include"] == ["metadatas", "distances"]




def test_similarity_search_with_scores_handles_non_positive_top_k():
    store = _build_store()

    assert store.similarity_search_with_scores(query_vector=[0.0, 1.0], top_k=0) == []

