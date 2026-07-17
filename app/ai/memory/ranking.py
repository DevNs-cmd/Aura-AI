from __future__ import annotations

import math
import re
from dataclasses import dataclass
from datetime import datetime, timezone
UTC = timezone.utc
from typing import Sequence

from app.ai.memory.exceptions import MemoryRankingError
from app.ai.memory.schemas import MemoryRead, MemoryRetrievalResult

TOKEN_RE = re.compile(r"[A-Za-z0-9_']+")


@dataclass(frozen=True)
class MemoryScoredCandidate:
    memory: MemoryRead
    vector_distance: float | None


class MemoryRanker:
    def __init__(
        self,
        *,
        vector_weight: float = 0.7,
        recency_weight: float = 0.2,
        lexical_weight: float = 0.1,
        recency_half_life_days: float = 30.0,
    ):
        total = vector_weight + recency_weight + lexical_weight
        if total <= 0:
            raise MemoryRankingError("Ranking weights must sum to a positive value")

        self.vector_weight = vector_weight
        self.recency_weight = recency_weight
        self.lexical_weight = lexical_weight
        self.recency_half_life_days = recency_half_life_days

    @staticmethod
    def _tokenize(text: str) -> set[str]:
        return {token.lower() for token in TOKEN_RE.findall(text)}

    @staticmethod
    def _similarity_from_distance(distance: float | None) -> float:
        if distance is None:
            return 0.0
        return 1.0 / (1.0 + max(distance, 0.0))

    def _recency_score(self, memory: MemoryRead) -> float:
        updated_at = memory.updated_at
        if updated_at.tzinfo is None:
            updated_at = updated_at.replace(tzinfo=UTC)

        age_days = max((datetime.now(UTC) - updated_at).total_seconds() / 86_400.0, 0.0)
        if self.recency_half_life_days <= 0:
            return 0.0
        return math.exp(-age_days / self.recency_half_life_days)

    def _lexical_score(self, query: str, memory: MemoryRead) -> float:
        query_tokens = self._tokenize(query)
        if not query_tokens:
            return 0.0

        content_tokens = self._tokenize(f"{memory.key} {memory.value} {memory.source}")
        if not content_tokens:
            return 0.0

        overlap = len(query_tokens & content_tokens)
        return overlap / len(query_tokens)

    def score(self, query: str, candidate: MemoryScoredCandidate) -> MemoryRetrievalResult:
        vector_score = self._similarity_from_distance(candidate.vector_distance)
        recency_score = self._recency_score(candidate.memory)
        lexical_score = self._lexical_score(query, candidate.memory)
        final_score = (
            self.vector_weight * vector_score
            + self.recency_weight * recency_score
            + self.lexical_weight * lexical_score
        )
        return MemoryRetrievalResult(
            memory=candidate.memory,
            score=final_score,
            vector_score=vector_score,
            recency_score=recency_score,
            lexical_score=lexical_score,
        )

    def rank(self, query: str, candidates: Sequence[MemoryScoredCandidate]) -> list[MemoryRetrievalResult]:
        scored_by_id: dict[str, MemoryRetrievalResult] = {}

        for candidate in candidates:
            scored = self.score(query, candidate)
            memory_id = str(scored.memory.id)
            existing = scored_by_id.get(memory_id)
            if existing is None or scored.score > existing.score:
                scored_by_id[memory_id] = scored

        return sorted(scored_by_id.values(), key=lambda item: item.score, reverse=True)


def build_memory_ranker() -> MemoryRanker:
    return MemoryRanker()
