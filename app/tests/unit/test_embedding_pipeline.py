from __future__ import annotations

from dataclasses import dataclass
from types import SimpleNamespace
from uuid import UUID

import pytest

from app.ai.embeddings.exceptions import EmbeddingRepositoryError, EmbeddingValidationError
from app.ai.embeddings.pipeline import EmbeddingPipeline


class FakeService:
    def __init__(self):
        self.provider = SimpleNamespace(provider_name="fake", model_name="fake-model")
        self.single_calls = []
        self.batch_calls = []

    def generate_embedding(self, text: str) -> list[float]:
        self.single_calls.append(text)
        return [1.0, 2.0, 3.0]

    def generate_batch_embeddings(self, texts):
        self.batch_calls.append(list(texts))
        return [[1.0, 2.0, 3.0] for _ in texts]


@dataclass
class FakeVectorStore:
    upserts: list[tuple[str, list[float], dict[str, object]]] = None
    batch_upserts: list[list[tuple[str, list[float], dict[str, object]]]] = None
    deleted: list[str] = None

    def __post_init__(self):
        self.upserts = []
        self.batch_upserts = []
        self.deleted = []

    def upsert(self, *, embedding_id, vector, metadata):
        self.upserts.append((embedding_id, list(vector), dict(metadata)))

    def upsert_batch(self, items):
        self.batch_upserts.append([(embedding_id, list(vector), dict(metadata)) for embedding_id, vector, metadata in items])

    def delete(self, embedding_id: str):
        self.deleted.append(embedding_id)


class FakeRepository:
    def __init__(self, *, fail_on_save: bool = False):
        self.saved = []
        self.saved_batch = []
        self.fail_on_save = fail_on_save

    def save(self, payload):
        if self.fail_on_save:
            raise EmbeddingRepositoryError("boom")
        self.saved.append(payload)
        return payload

    def save_batch(self, payloads):
        if self.fail_on_save:
            raise EmbeddingRepositoryError("boom")
        self.saved_batch.extend(payloads)
        return list(payloads)


def test_preprocess_text_collapses_whitespace_and_normalizes():
    pipeline = EmbeddingPipeline(service=FakeService())

    assert pipeline.preprocess_text("  Cafe\u0301   ai  ") == "Café ai"


def test_generate_embedding_preprocesses_before_service_call():
    service = FakeService()
    pipeline = EmbeddingPipeline(service=service)

    vector = pipeline.generate_embedding("  Hello   world  ")

    assert vector == [1.0, 2.0, 3.0]
    assert service.single_calls == ["Hello world"]


def test_generate_embedding_persists_payload_and_links_vectorstore_and_repository(monkeypatch):
    service = FakeService()
    vector_store = FakeVectorStore()
    repository = FakeRepository()
    pipeline = EmbeddingPipeline(service=service, vector_store=vector_store, repository=repository)

    monkeypatch.setattr("app.ai.embeddings.pipeline.uuid.uuid4", lambda: UUID("00000000-0000-0000-0000-000000000001"))

    vector = pipeline.generate_embedding(
        "  Hello   world  ",
        persist=True,
        source_type="document",
        source_id="doc-1",
        metadata={"language": "en"},
    )

    assert vector == [1.0, 2.0, 3.0]
    assert len(vector_store.upserts) == 1
    assert len(repository.saved) == 1
    assert vector_store.upserts[0][0] == repository.saved[0].id
    assert repository.saved[0].source_type == "document"
    assert repository.saved[0].source_id == "doc-1"
    assert repository.saved[0].content_hash
    assert vector_store.upserts[0][2]["language"] == "en"


def test_generate_batch_embeddings_persists_payloads_in_order(monkeypatch):
    service = FakeService()
    vector_store = FakeVectorStore()
    repository = FakeRepository()
    pipeline = EmbeddingPipeline(service=service, vector_store=vector_store, repository=repository)

    ids = iter(
        [
            UUID("00000000-0000-0000-0000-000000000001"),
            UUID("00000000-0000-0000-0000-000000000002"),
        ]
    )
    monkeypatch.setattr("app.ai.embeddings.pipeline.uuid.uuid4", lambda: next(ids))

    vectors = pipeline.generate_batch_embeddings(
        ["  First  text ", "Second   text"],
        persist=True,
        source_type="memory",
        source_id="mem-1",
        metadata={"kind": "batch"},
    )

    assert vectors == [[1.0, 2.0, 3.0], [1.0, 2.0, 3.0]]
    assert len(vector_store.batch_upserts) == 1
    assert len(repository.saved_batch) == 2
    assert [item.source_type for item in repository.saved_batch] == ["memory", "memory"]
    assert [item.source_id for item in repository.saved_batch] == ["mem-1", "mem-1"]
    assert [item.id for item in repository.saved_batch] == [item[0] for item in vector_store.batch_upserts[0]]


def test_generate_embedding_requires_repository_when_persisting():
    pipeline = EmbeddingPipeline(service=FakeService())

    with pytest.raises(EmbeddingValidationError):
        pipeline.generate_embedding("hello", persist=True)


def test_generate_embedding_rolls_back_vectorstore_write_on_repository_failure():
    service = FakeService()
    vector_store = FakeVectorStore()
    repository = FakeRepository(fail_on_save=True)
    pipeline = EmbeddingPipeline(service=service, vector_store=vector_store, repository=repository)

    with pytest.raises(EmbeddingRepositoryError):
        pipeline.generate_embedding("hello", persist=True)

    assert len(vector_store.upserts) == 1
    assert len(vector_store.deleted) == 1
