from __future__ import annotations

import uuid
from dataclasses import dataclass

import pytest
from sqlalchemy import create_engine
from sqlalchemy.orm import sessionmaker

from app.ai.embeddings.provider import DeterministicEmbeddingProvider
from app.ai.embeddings.service import EmbeddingService
from app.ai.journal.pipeline import JournalPipeline
from app.ai.journal.repository import SQLAlchemyJournalRepository
from app.ai.journal.schemas import JournalEntryCreate, JournalEntryUpdate
from app.ai.journal.service import JournalService
from app.ai.memory.repository import SQLAlchemyMemoryRepository
from app.ai.memory.service import MemoryService
from app.db.database import Base
from app.models.journal import JournalEntry
from app.models.user import User


@dataclass
class InMemoryVectorStore:
    records: list[tuple[str, list[float], dict]] = None

    def __post_init__(self):
        self.records = []

    def upsert(self, *, embedding_id, vector, metadata):
        self.records.append((embedding_id, [float(v) for v in vector], dict(metadata)))

    def upsert_batch(self, items):
        for embedding_id, vector, metadata in items:
            self.upsert(embedding_id=embedding_id, vector=vector, metadata=metadata)

    def delete(self, embedding_id: str):
        self.records = [record for record in self.records if record[0] != embedding_id]

    def similarity_search(self, *, query_vector, top_k, filters=None):
        return []

    def similarity_search_with_scores(self, *, query_vector, top_k, filters=None):
        return []


class FakeCache:
    def __init__(self):
        self.store = {}

    def get(self, key: str):
        return self.store.get(key)

    def set(self, key: str, value: str, *, ttl_seconds: int | None = None):
        self.store[key] = value

    def delete(self, *keys: str):
        for key in keys:
            self.store.pop(key, None)

    def increment(self, key: str) -> int:
        current = int(self.store.get(key, 0)) + 1
        self.store[key] = str(current)
        return current


@pytest.mark.integration
def test_journal_roundtrip_with_database_embedding_and_memory_stack():
    engine = create_engine("sqlite:///:memory:")
    Base.metadata.create_all(bind=engine)
    SessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=engine)
    session = SessionLocal()

    try:
        repo = SQLAlchemyJournalRepository(db=session)
        memory_repo = SQLAlchemyMemoryRepository(db=session)
        vector_store = InMemoryVectorStore()
        embedding_service = EmbeddingService(
            provider=DeterministicEmbeddingProvider(model_name="integration-model", dimension=16)
        )
        memory_service = MemoryService(repository=memory_repo)
        pipeline = JournalPipeline(
            repository=repo,
            embedding_service=embedding_service,
            vector_store=vector_store,
            memory_service=memory_service,
        )
        service = JournalService(db=session, repository=repo, cache=FakeCache(), pipeline=pipeline)

        user_id = uuid.uuid4()
        created = service.create_entry(
            user_id=user_id,
            payload=JournalEntryCreate(title="A warm day", content="I felt calm, grateful, and focused."),
        )
        updated = service.update_entry(
            user_id=user_id,
            entry_id=created.id,
            payload=JournalEntryUpdate(content="I felt calm, grateful, and focused about my work."),
        )
        listed = service.list_entries(user_id=user_id)
        fetched = service.get_entry(user_id=user_id, entry_id=created.id)
        deleted = service.delete_entry(user_id=user_id, entry_id=created.id)

        assert created.id == fetched.id == listed[0].id == updated.id
        assert created.summary
        assert created.mood in {"calm", "joyful", "hopeful", "reflective", "neutral"}
        assert created.reflection
        assert vector_store.records
        assert deleted.deleted_at is not None
        assert session.query(JournalEntry).filter(JournalEntry.deleted_at.is_(None)).count() == 0
        assert session.query(User).count() == 0
    finally:
        session.close()
        Base.metadata.drop_all(bind=engine)
        engine.dispose()
