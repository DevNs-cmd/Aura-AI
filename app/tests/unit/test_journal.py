from __future__ import annotations

from dataclasses import dataclass
from uuid import uuid4

import pytest
from sqlalchemy import create_engine
from sqlalchemy.orm import sessionmaker

from app.ai.embeddings.provider import DeterministicEmbeddingProvider
from app.ai.embeddings.service import EmbeddingService
from app.ai.journal.cache import RedisJournalCache
from app.ai.journal.pipeline import JournalPipeline
from app.ai.journal.repository import SQLAlchemyJournalRepository
from app.ai.journal.schemas import JournalArtifactUpdate, JournalEntryCreate, JournalEntryUpdate
from app.ai.journal.service import JournalService
from app.ai.journal.exceptions import JournalNotFoundError
from app.ai.memory.repository import SQLAlchemyMemoryRepository
from app.ai.memory.service import MemoryService
from app.ai.vectorstore import VectorStoreSearchResultWithScore
from app.db.database import Base
from app.models.user import User


class FakeRedisClient:
    def __init__(self):
        self.data = {}

    def get(self, key):
        return self.data.get(key)

    def set(self, key, value, ex=None):
        self.data[key] = value
        self.data[f"{key}:ttl"] = ex
        return True

    def delete(self, *keys):
        for key in keys:
            self.data.pop(key, None)
            self.data.pop(f"{key}:ttl", None)
        return len(keys)

    def incr(self, key):
        value = int(self.data.get(key, 0)) + 1
        self.data[key] = str(value)
        return value


@dataclass
class InMemoryVectorStore:
    records: list[tuple[str, list[float], dict]] = None
    deleted: list[str] = None

    def __post_init__(self):
        self.records = []
        self.deleted = []

    def upsert(self, *, embedding_id, vector, metadata):
        self.records.append((embedding_id, [float(v) for v in vector], dict(metadata)))

    def upsert_batch(self, items):
        for embedding_id, vector, metadata in items:
            self.upsert(embedding_id=embedding_id, vector=vector, metadata=metadata)

    def delete(self, embedding_id: str):
        self.deleted.append(embedding_id)
        self.records = [record for record in self.records if record[0] != embedding_id]

    def similarity_search(self, *, query_vector, top_k, filters=None):
        return []

    def similarity_search_with_scores(self, *, query_vector, top_k, filters=None):
        return []


class FakeEmbeddingService:
    def __init__(self):
        self.calls = []

    def embed_text(self, text: str):
        self.calls.append(text)
        return [1.0, 0.0, 0.0]


class FakeMemoryService:
    def __init__(self):
        self.calls = []

    def upsert_memories(self, payloads):
        self.calls.append(list(payloads))
        return []


def make_session():
    engine = create_engine("sqlite:///:memory:")
    Base.metadata.create_all(bind=engine)
    SessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=engine)
    return engine, SessionLocal()


def test_journal_cache_versions_payloads():
    client = FakeRedisClient()
    cache = RedisJournalCache(client=client, ttl_seconds=120)

    assert cache.increment("journal:user:1:version") == 1
    cache.set("journal:user:1:version", "1")
    assert cache.get("journal:user:1:version") == "1"
    cache.delete("journal:user:1:version")
    assert cache.get("journal:user:1:version") is None


def test_repository_crud_and_soft_delete():
    engine, session = make_session()
    try:
        repo = SQLAlchemyJournalRepository(db=session)
        user_id = uuid4()

        created = repo.create(user_id=user_id, payload=JournalEntryCreate(title="First", content="A calm day."))
        assert created.title == "First"

        updated = repo.update(created.id, JournalEntryUpdate(content="A more reflective day."))
        assert updated.content == "A more reflective day."

        artifact_payload = JournalArtifactUpdate(
            summary="Summary",
            mood="calm",
            keywords=["calm"],
            reflection="Reflection",
            follow_up_suggestions=["Suggestion"],
            embedding_id=str(created.id),
        )
        stored = repo.update_artifacts(created.id, artifact_payload)
        assert stored.summary == "Summary"
        assert stored.artifacts["embedding_id"] == str(created.id)

        listed = repo.list_by_user(user_id)
        assert [item.id for item in listed] == [created.id]

        deleted = repo.delete(created.id)
        assert deleted.deleted_at is not None
        assert repo.get_by_id(created.id) is None
    finally:
        session.close()
        Base.metadata.drop_all(bind=engine)
        engine.dispose()


def test_service_caches_and_invalidates_reads():
    engine, session = make_session()
    try:
        repo = SQLAlchemyJournalRepository(db=session)
        cache = RedisJournalCache(client=FakeRedisClient(), ttl_seconds=120)
        vector_store = InMemoryVectorStore()
        embedding_service = FakeEmbeddingService()
        memory_service = FakeMemoryService()
        pipeline = JournalPipeline(
            repository=repo,
            embedding_service=embedding_service,
            vector_store=vector_store,
            memory_service=memory_service,
        )
        service = JournalService(db=session, repository=repo, cache=cache, pipeline=pipeline)
        user_id = uuid4()

        created = service.create_entry(user_id=user_id, payload=JournalEntryCreate(title="Morning", content="I felt calm and hopeful."))
        fetched = service.get_entry(user_id=user_id, entry_id=created.id)
        listed = service.list_entries(user_id=user_id)
        updated = service.update_entry(user_id=user_id, entry_id=created.id, payload=JournalEntryUpdate(content="I felt reflective."))
        deleted = service.delete_entry(user_id=user_id, entry_id=created.id)

        assert fetched.id == created.id
        assert listed[0].id == created.id
        assert updated.content == "I felt reflective."
        assert deleted.deleted_at is not None
        assert embedding_service.calls
        assert memory_service.calls

        with pytest.raises(JournalNotFoundError):
            service.get_entry(user_id=user_id, entry_id=created.id)
    finally:
        session.close()
        Base.metadata.drop_all(bind=engine)
        engine.dispose()
