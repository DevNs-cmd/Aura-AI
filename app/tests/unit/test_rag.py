from __future__ import annotations

from datetime import datetime, timezone
UTC = timezone.utc
from types import SimpleNamespace
from uuid import uuid4

import pytest

from app.ai.rag.exceptions import RagRetrievalError
from app.ai.rag.pipeline import RagPipeline
from app.ai.rag.ranking import RagRanker
from app.ai.rag.retrieval import RagChunkCandidate
from app.ai.vectorstore import VectorStoreSearchResultWithScore


class FakeEmbeddingService:
    def __init__(self, vector: list[float] | None = None, *, fail: bool = False):
        self.vector = vector or [0.25, 0.5, 0.75]
        self.fail = fail
        self.last_text = None

    def generate_embedding(self, text: str) -> list[float]:
        self.last_text = text
        if self.fail:
            raise RuntimeError("embedding failed")
        return list(self.vector)


class FakeVectorStore:
    def __init__(self, results=None, *, fail: bool = False):
        self.results = results or []
        self.fail = fail
        self.query_calls = 0
        self.last_query_kwargs = None

    def similarity_search_with_scores(self, *, query_vector, top_k, filters=None):
        self.query_calls += 1
        self.last_query_kwargs = {
            "query_vector": list(query_vector),
            "top_k": top_k,
            "filters": filters,
        }
        if self.fail:
            raise RuntimeError("vector store failed")
        return list(self.results)


class FakeDocumentRepository:
    def __init__(self, documents=None):
        self.documents = {str(document.id): document for document in (documents or [])}
        self.get_by_ids_calls = 0
        self.last_document_ids = None

    def get_by_id(self, document_id):
        return self.documents.get(str(document_id))

    def get_by_ids(self, document_ids):
        self.get_by_ids_calls += 1
        self.last_document_ids = [str(document_id) for document_id in document_ids]
        return [self.documents[str(document_id)] for document_id in document_ids if str(document_id) in self.documents]


def _document(*, document_id=None):
    now = datetime.now(UTC)
    return SimpleNamespace(
        id=document_id or uuid4(),
        user_id=uuid4(),
        filename="guide.md",
        file_path="/tmp/guide.md",
        file_type="text/markdown",
        size_bytes=128,
        status="indexed",
        created_at=now,
    )


def _vector_result(*, embedding_id: str, document_id, chunk_id: str, chunk_text: str, distance: float):
    return VectorStoreSearchResultWithScore(
        embedding_id=embedding_id,
        metadata={
            "document_id": str(document_id),
            "chunk_id": chunk_id,
            "chunk_text": chunk_text,
            "source_type": "document",
        },
        score=distance,
    )


def test_pipeline_generates_query_embedding_and_uses_document_metadata():
    document = _document()
    service = FakeEmbeddingService()
    vector_store = FakeVectorStore(
        results=[
            _vector_result(
                embedding_id="embedding-1",
                document_id=document.id,
                chunk_id="chunk-1",
                chunk_text="alpha beta",
                distance=0.2,
            )
        ]
    )
    repository = FakeDocumentRepository([document])
    pipeline = RagPipeline(
        embedding_service=service,
        vector_store=vector_store,
        document_repository=repository,
    )

    results = pipeline.retrieve_chunks("  alpha beta  ", top_k=1)

    assert service.last_text == "alpha beta"
    assert vector_store.query_calls == 1
    assert vector_store.last_query_kwargs["query_vector"] == [0.25, 0.5, 0.75]
    assert vector_store.last_query_kwargs["top_k"] == 4
    assert repository.get_by_ids_calls == 1
    assert results[0].document_id == document.id
    assert results[0].chunk_id == "chunk-1"
    assert results[0].chunk_text == "alpha beta"
    assert results[0].metadata["document"]["filename"] == "guide.md"
    assert results[0].metadata["chunk"]["embedding_id"] == "embedding-1"


def test_ranker_orders_by_similarity_and_deduplicates_chunks():
    document_id = uuid4()
    now = datetime.now(UTC)
    candidate_low = RagChunkCandidate(
        embedding_id="embedding-low",
        document_id=document_id,
        chunk_id="chunk-1",
        chunk_text="lower score",
        metadata={"document_id": str(document_id), "chunk_text": "lower score"},
        vector_distance=0.9,
    )
    candidate_high = RagChunkCandidate(
        embedding_id="embedding-high",
        document_id=document_id,
        chunk_id="chunk-1",
        chunk_text="higher score",
        metadata={"document_id": str(document_id), "chunk_text": "higher score"},
        vector_distance=0.1,
    )
    ranker = RagRanker()

    ranked = ranker.rank([candidate_low, candidate_high])

    assert len(ranked) == 1
    assert ranked[0].chunk_text == "higher score"
    assert ranked[0].similarity_score > 0.9


def test_pipeline_respects_top_k():
    document = _document()
    service = FakeEmbeddingService()
    vector_store = FakeVectorStore(
        results=[
            _vector_result(
                embedding_id="embedding-1",
                document_id=document.id,
                chunk_id="chunk-1",
                chunk_text="first",
                distance=0.8,
            ),
            _vector_result(
                embedding_id="embedding-2",
                document_id=document.id,
                chunk_id="chunk-2",
                chunk_text="second",
                distance=0.2,
            ),
            _vector_result(
                embedding_id="embedding-3",
                document_id=document.id,
                chunk_id="chunk-3",
                chunk_text="third",
                distance=0.4,
            ),
        ]
    )
    repository = FakeDocumentRepository([document])
    pipeline = RagPipeline(
        embedding_service=service,
        vector_store=vector_store,
        document_repository=repository,
    )

    results = pipeline.retrieve_chunks("query", top_k=2)

    assert len(results) == 2
    assert [result.chunk_id for result in results] == ["chunk-2", "chunk-3"]


def test_pipeline_returns_empty_list_when_vector_store_has_no_matches():
    document = _document()
    pipeline = RagPipeline(
        embedding_service=FakeEmbeddingService(),
        vector_store=FakeVectorStore(results=[]),
        document_repository=FakeDocumentRepository([document]),
    )

    assert pipeline.retrieve_chunks("query", top_k=3) == []


def test_pipeline_wraps_unexpected_failures():
    document = _document()
    pipeline = RagPipeline(
        embedding_service=FakeEmbeddingService(),
        vector_store=FakeVectorStore(fail=True),
        document_repository=FakeDocumentRepository([document]),
    )

    with pytest.raises(RagRetrievalError):
        pipeline.retrieve_chunks("query", top_k=1)
