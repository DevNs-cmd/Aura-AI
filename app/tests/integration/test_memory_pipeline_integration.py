from __future__ import annotations

import math
import uuid
from dataclasses import dataclass

import pytest
from sqlalchemy import create_engine
from sqlalchemy.orm import sessionmaker

from app.ai.embeddings.provider import DeterministicEmbeddingProvider
from app.ai.embeddings.service import EmbeddingService
from app.ai.embeddings.pipeline import EmbeddingPipeline
from app.ai.memory.cache import RedisMemoryCache
from app.ai.memory.pipeline import MemoryPipeline
from app.ai.memory.repository import SQLAlchemyMemoryRepository
from app.ai.memory.service import MemoryService
from app.ai.memory.schemas import MemoryCreate
from app.ai.memory.ranking import MemoryRanker
from app.ai.vectorstore import VectorStoreSearchResultWithScore
from app.db.database import Base
from app.models.embedding import EmbeddingRecord
from app.models.user import User
from app.repositories.embedding_repository import SQLAlchemyEmbeddingRepository


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

    @staticmethod
    def _distance(a: list[float], b: list[float]) -> float:
        dot = sum(x * y for x, y in zip(a, b, strict=True))
        norm_a = math.sqrt(sum(x * x for x in a))
        norm_b = math.sqrt(sum(x * x for x in b))
        if norm_a == 0 or norm_b == 0:
            return 1.0
        cosine = dot / (norm_a * norm_b)
        return 1.0 - cosine

    def similarity_search_with_scores(self, *, query_vector, top_k, filters=None):
        candidates = []
        for embedding_id, vector, metadata in self.records:
            if filters:
                if any(metadata.get(key) != value for key, value in filters.items()):
                    continue
            distance = self._distance(list(query_vector), vector)
            candidates.append(
                VectorStoreSearchResultWithScore(
                    embedding_id=embedding_id,
                    metadata=dict(metadata),
                    score=distance,
                )
            )
        candidates.sort(key=lambda item: item.score)
        return candidates[:top_k]


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
def test_memory_pipeline_roundtrip_with_vector_search(tmp_path):
    engine = create_engine("sqlite:///:memory:")
    Base.metadata.create_all(bind=engine)
    SessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=engine)
    session = SessionLocal()

    try:
        vector_store = InMemoryVectorStore()
        embedding_repo = SQLAlchemyEmbeddingRepository(db=session)
        memory_repo = SQLAlchemyMemoryRepository(db=session)
        embedding_service = EmbeddingService(provider=DeterministicEmbeddingProvider(model_name="integration-model", dimension=16))
        embedding_pipeline = EmbeddingPipeline(
            service=embedding_service,
            vector_store=vector_store,
            repository=embedding_repo,
        )
        memory_service = MemoryService(
            repository=memory_repo,
            cache=FakeCache(),
            embedding_service=embedding_service,
            vector_store=vector_store,
            ranker=MemoryRanker(),
        )
        pipeline = MemoryPipeline(service=memory_service, embedding_pipeline=embedding_pipeline)

        user_id = uuid.uuid4()
        created = pipeline.create_memory(
            MemoryCreate(user_id=user_id, key="favorite_food", value="biryani", source="chat")
        )
        pipeline.create_memory(MemoryCreate(user_id=user_id, key="favorite_city", value="pune", source="chat"))

        results = memory_service.retrieve_memories("favorite food", user_id=user_id, top_k=2)

        assert created.id == results[0].memory.id
        assert results[0].memory.key == "favorite_food"
        assert len(session.query(EmbeddingRecord).all()) == 2
    finally:
        session.close()
        Base.metadata.drop_all(bind=engine)
        engine.dispose()
