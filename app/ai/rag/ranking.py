from __future__ import annotations

from dataclasses import dataclass
from typing import Sequence

from app.ai.rag.retrieval import RagChunkCandidate
from app.ai.rag.schemas import RagRetrievalResult
from app.ai.rag.utils import build_chunk_metadata, merge_metadata


@dataclass(frozen=True)
class RagScoredChunk:
    candidate: RagChunkCandidate
    similarity_score: float


class RagRanker:
    @staticmethod
    def _similarity_from_distance(distance: float | None) -> float:
        if distance is None:
            return 0.0
        return 1.0 / (1.0 + max(distance, 0.0))

    def score(self, candidate: RagChunkCandidate, *, document: object | None = None) -> RagRetrievalResult:
        similarity_score = self._similarity_from_distance(candidate.vector_distance)
        return RagRetrievalResult(
            document_id=candidate.document_id,
            chunk_id=candidate.chunk_id,
            chunk_text=candidate.chunk_text,
            similarity_score=similarity_score,
            metadata=merge_metadata(
                document=document,
                chunk_metadata=build_chunk_metadata(
                    candidate.metadata,
                    embedding_id=candidate.embedding_id,
                    chunk_id=candidate.chunk_id,
                ),
            ),
        )

    def rank(
        self,
        candidates: Sequence[RagChunkCandidate],
        *,
        documents_by_id: dict[str, object] | None = None,
    ) -> list[RagRetrievalResult]:
        scored_by_key: dict[str, RagRetrievalResult] = {}

        for candidate in candidates:
            document = None
            if documents_by_id is not None:
                document = documents_by_id.get(str(candidate.document_id))

            scored = self.score(candidate, document=document)
            key = f"{scored.document_id}:{scored.chunk_id}"
            existing = scored_by_key.get(key)
            if existing is None or scored.similarity_score > existing.similarity_score:
                scored_by_key[key] = scored

        return sorted(
            scored_by_key.values(),
            key=lambda item: item.similarity_score,
            reverse=True,
        )


def build_rag_ranker() -> RagRanker:
    return RagRanker()
