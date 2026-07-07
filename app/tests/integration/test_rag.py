from __future__ import annotations

from pathlib import Path
from uuid import uuid4

import pytest
from sqlalchemy import create_engine
from sqlalchemy.orm import sessionmaker

from app.ai.embeddings.provider import DeterministicEmbeddingProvider
from app.ai.embeddings.service import EmbeddingService
from app.ai.rag.pipeline import RagPipeline
from app.ai.rag.repository import SQLAlchemyDocumentRepository
from app.ai.rag.service import RagService
from app.ai.vectorstore.chroma import ChromaVectorStore
from app.db.database import Base
from app.models.document import Document
from app.models.user import User


@pytest.mark.integration
def test_rag_end_to_end_retrieval(tmp_path):
    try:
        import chromadb  # noqa: F401
    except ImportError:
        pytest.skip("chromadb not installed")

    engine = create_engine("sqlite:///:memory:")
    Base.metadata.create_all(bind=engine)
    SessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=engine)
    session = SessionLocal()

    try:
        user = User(
            email=f"rag-{uuid4()}@example.com",
            hashed_password="hashed-password",
            full_name="RAG Test User",
            is_active=True,
        )
        session.add(user)
        session.commit()
        session.refresh(user)

        document = Document(
            user_id=user.id,
            filename="handbook.md",
            file_path=str(Path(tmp_path) / "handbook.md"),
            file_type="text/markdown",
            size_bytes=256,
            status="indexed",
        )
        session.add(document)
        session.commit()
        session.refresh(document)

        embedding_service = EmbeddingService(
            provider=DeterministicEmbeddingProvider(model_name="rag-integration-model", dimension=32)
        )
        vector_store = ChromaVectorStore(
            collection_name=f"rag-test-{uuid4()}",
            persist_directory=str(tmp_path / "chroma"),
        )
        repository = SQLAlchemyDocumentRepository(db=session)

        chunk_text = "How to use the onboarding handbook"
        vector_store.upsert(
            embedding_id="chunk-embedding-1",
            vector=embedding_service.generate_embedding(chunk_text),
            metadata={
                "document_id": str(document.id),
                "chunk_id": "chunk-1",
                "chunk_text": chunk_text,
                "source_type": "document",
            },
        )

        pipeline = RagPipeline(
            embedding_service=embedding_service,
            vector_store=vector_store,
            document_repository=repository,
        )
        service = RagService(pipeline=pipeline)

        results = service.retrieve_chunks("onboarding handbook", top_k=1)

        assert len(results) == 1
        result = results[0]
        assert result.document_id == document.id
        assert result.chunk_id == "chunk-1"
        assert result.chunk_text == chunk_text
        assert result.similarity_score > 0
        assert result.metadata["document"]["filename"] == "handbook.md"
        assert result.metadata["chunk"]["chunk_id"] == "chunk-1"
    finally:
        session.close()
        Base.metadata.drop_all(bind=engine)
        engine.dispose()
