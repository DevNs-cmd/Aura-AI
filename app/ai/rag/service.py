from __future__ import annotations

from sqlalchemy.orm import Session

from app.ai.embeddings.service import EmbeddingService, build_embedding_service
from app.ai.rag.exceptions import RagConfigurationError
from app.ai.rag.pipeline import RagPipeline, build_rag_pipeline
from app.ai.rag.repository import DocumentRepository, build_document_repository
from app.ai.rag.schemas import RagRetrievalResult
from app.ai.vectorstore import VectorStore, build_vector_store


class RagService:
    def __init__(self, *, pipeline: RagPipeline):
        self.pipeline = pipeline

    def retrieve_chunks(self, query: str, *, top_k: int = 5) -> list[RagRetrievalResult]:
        return self.pipeline.retrieve_chunks(query, top_k=top_k)


def build_rag_service(
    *,
    db: Session | None = None,
    embedding_service: EmbeddingService | None = None,
    vector_store: VectorStore | None = None,
    document_repository: DocumentRepository | None = None,
    pipeline: RagPipeline | None = None,
) -> RagService:
    if pipeline is None:
        if embedding_service is None:
            embedding_service = build_embedding_service()
        if vector_store is None:
            vector_store = build_vector_store()
        if document_repository is None:
            if db is None:
                raise RagConfigurationError("A database session is required to build the RAG service")
            document_repository = build_document_repository(db)
        pipeline = build_rag_pipeline(
            embedding_service=embedding_service,
            vector_store=vector_store,
            document_repository=document_repository,
        )

    return RagService(pipeline=pipeline)
