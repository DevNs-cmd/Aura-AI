from __future__ import annotations

from dataclasses import dataclass
from typing import Any
from uuid import UUID

from app.ai.vectorstore import VectorStoreSearchResultWithScore
from app.ai.rag.utils import extract_chunk_id, extract_chunk_text, extract_document_id


@dataclass(frozen=True)
class RagChunkCandidate:
    embedding_id: str
    document_id: UUID
    chunk_id: str
    chunk_text: str
    metadata: dict[str, Any]
    vector_distance: float | None


def build_chunk_candidate(result: VectorStoreSearchResultWithScore) -> RagChunkCandidate | None:
    document_id = extract_document_id(result.metadata)
    chunk_text = extract_chunk_text(result.metadata)
    if document_id is None or chunk_text is None:
        return None

    chunk_id = extract_chunk_id(result.metadata, result.embedding_id)
    return RagChunkCandidate(
        embedding_id=result.embedding_id,
        document_id=document_id,
        chunk_id=chunk_id,
        chunk_text=chunk_text,
        metadata=dict(result.metadata),
        vector_distance=result.score,
    )
