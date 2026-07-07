from __future__ import annotations

from dataclasses import dataclass

from sqlalchemy import create_engine
from sqlalchemy.orm import sessionmaker

from app.ai.embeddings.pipeline import EmbeddingPipeline
from app.ai.embeddings.provider import DeterministicEmbeddingProvider
from app.ai.embeddings.service import EmbeddingService
from app.db.database import Base
from app.models.embedding import EmbeddingRecord
from app.repositories.embedding_repository import SQLAlchemyEmbeddingRepository


@dataclass
class RecordingVectorStore:
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


def test_pipeline_persists_metadata_in_postgresql_and_vectors_in_vectorstore():
    engine = create_engine("sqlite:///:memory:")
    Base.metadata.create_all(bind=engine)
    SessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=engine)
    session = SessionLocal()

    try:
        repository = SQLAlchemyEmbeddingRepository(db=session)
        vector_store = RecordingVectorStore()
        provider = DeterministicEmbeddingProvider(model_name="integration-model", dimension=32)
        service = EmbeddingService(provider=provider)
        pipeline = EmbeddingPipeline(service=service, vector_store=vector_store, repository=repository)

        vector = pipeline.generate_embedding(
            "  Hello   world  ",
            persist=True,
            source_type="document",
            source_id="doc-1",
            metadata={"origin": "integration-test"},
        )

        assert len(vector) == 32
        assert len(vector_store.upserts) == 1
        assert vector_store.upserts[0][1] == vector

        record = repository.list_by_source(source_type="document", source_id="doc-1", limit=1)[0]
        assert record.provider == "deterministic"
        assert record.model_name == "integration-model"
        assert record.content_hash
        assert EmbeddingRecord.__table__.columns.keys() == [
            "id",
            "source_type",
            "source_id",
            "content_hash",
            "provider",
            "model_name",
            "created_at",
        ]
    finally:
        session.close()
        Base.metadata.drop_all(bind=engine)
        engine.dispose()


def test_batch_pipeline_persists_multiple_embeddings():
    engine = create_engine("sqlite:///:memory:")
    Base.metadata.create_all(bind=engine)
    SessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=engine)
    session = SessionLocal()

    try:
        repository = SQLAlchemyEmbeddingRepository(db=session)
        vector_store = RecordingVectorStore()
        provider = DeterministicEmbeddingProvider(model_name="integration-model", dimension=24)
        service = EmbeddingService(provider=provider)
        pipeline = EmbeddingPipeline(service=service, vector_store=vector_store, repository=repository)

        vectors = pipeline.generate_batch_embeddings(
            ["  First  text ", "Second   text"],
            persist=True,
            source_type="memory",
            source_id="mem-1",
        )

        assert len(vectors) == 2
        assert len(vector_store.batch_upserts) == 1
        records = (
            session.query(EmbeddingRecord)
            .filter(EmbeddingRecord.source_type == "memory", EmbeddingRecord.source_id == "mem-1")
            .order_by(EmbeddingRecord.created_at.asc())
            .all()
        )
        assert len(records) == 2
        assert [record.provider for record in records] == ["deterministic", "deterministic"]
        assert [record.model_name for record in records] == ["integration-model", "integration-model"]
        assert [len(vector) for vector in vectors] == [24, 24]
    finally:
        session.close()
        Base.metadata.drop_all(bind=engine)
        engine.dispose()
