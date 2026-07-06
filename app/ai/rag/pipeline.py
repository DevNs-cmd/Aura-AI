from __future__ import annotations

from app.ai.embeddings.exceptions import EmbeddingValidationError
from app.ai.embeddings.service import EmbeddingService
from app.ai.rag.exceptions import RagConfigurationError, RagRetrievalError, RagValidationError
from app.ai.rag.ranking import RagRanker, build_rag_ranker
from app.ai.rag.repository import DocumentRepository
from app.ai.rag.retrieval import RagChunkCandidate, build_chunk_candidate
from app.ai.rag.schemas import RagRetrievalResult
from app.ai.rag.utils import normalize_query
from app.ai.vectorstore import VectorStore


class RagPipeline:
    def __init__(
        self,
        *,
        embedding_service: EmbeddingService,
        vector_store: VectorStore,
        document_repository: DocumentRepository,
        ranker: RagRanker | None = None,
        candidate_multiplier: int = 4,
    ):
        self.embedding_service = embedding_service
        self.vector_store = vector_store
        self.document_repository = document_repository
        self.ranker = ranker or build_rag_ranker()
        self.candidate_multiplier = max(candidate_multiplier, 1)

    def _resolve_documents(self, candidates: list[RagChunkCandidate]) -> dict[str, object]:
        document_ids = sorted({candidate.document_id for candidate in candidates}, key=str)
        documents = self.document_repository.get_by_ids(document_ids)
        return {str(document.id): document for document in documents}

    def retrieve_chunks(self, query: str, *, top_k: int = 5) -> list[RagRetrievalResult]:
        if top_k <= 0:
            return []

        try:
            normalized_query = normalize_query(query)
            query_vector = self.embedding_service.generate_embedding(normalized_query)

            vector_results = self.vector_store.similarity_search_with_scores(
                query_vector=query_vector,
                top_k=max(top_k * self.candidate_multiplier, top_k),
            )

            candidates: list[RagChunkCandidate] = []
            for result in vector_results:
                candidate = build_chunk_candidate(result)
                if candidate is not None:
                    candidates.append(candidate)

            if not candidates:
                return []

            documents_by_id = self._resolve_documents(candidates)
            ranked = self.ranker.rank(candidates, documents_by_id=documents_by_id)
            return ranked[:top_k]
        except (EmbeddingValidationError, RagValidationError):
            raise
        except Exception as exc:  # pragma: no cover - adapter boundary
            raise RagRetrievalError("Failed to retrieve document chunks") from exc


def build_rag_pipeline(
    *,
    embedding_service: EmbeddingService,
    vector_store: VectorStore,
    document_repository: DocumentRepository,
    ranker: RagRanker | None = None,
) -> RagPipeline:
    if embedding_service is None:
        raise RagConfigurationError("An embedding service is required to build the RAG pipeline")
    if vector_store is None:
        raise RagConfigurationError("A vector store is required to build the RAG pipeline")
    if document_repository is None:
        raise RagConfigurationError("A document repository is required to build the RAG pipeline")

    return RagPipeline(
        embedding_service=embedding_service,
        vector_store=vector_store,
        document_repository=document_repository,
        ranker=ranker,
    )
