from __future__ import annotations

import os
import uuid

import pytest

from app.ai.vectorstore.chroma import ChromaVectorStore


@pytest.mark.integration
def test_chroma_similarity_search_roundtrip(tmp_path):
    # Requires chromadb at runtime.
    try:
        import chromadb  # noqa: F401
    except ImportError:
        pytest.skip("chromadb not installed")

    persist_dir = str(tmp_path / "chroma")
    store = ChromaVectorStore(
        collection_name=f"test-{uuid.uuid4()}",
        persist_directory=persist_dir,
    )

    # Upsert two simple vectors with distinct ids and metadata.
    id_a = str(uuid.uuid4())
    id_b = str(uuid.uuid4())

    store.upsert(
        embedding_id=id_a,
        vector=[1.0, 0.0, 0.0],
        metadata={"source_type": "test", "label": "a"},
    )
    store.upsert(
        embedding_id=id_b,
        vector=[0.0, 1.0, 0.0],
        metadata={"source_type": "test", "label": "b"},
    )

    # Query close to vector [1,0,0] should prefer id_a.
    results = store.similarity_search(query_vector=[1.0, 0.0, 0.0], top_k=1)
    assert len(results) == 1
    assert results[0].embedding_id == id_a

    results_scored = store.similarity_search_with_scores(
        query_vector=[1.0, 0.0, 0.0],
        top_k=2,
        filters={"source_type": "test"},
    )
    assert len(results_scored) == 2
    assert all(r.metadata.get("source_type") == "test" for r in results_scored)

