from __future__ import annotations

from datetime import datetime, timezone, timedelta
UTC = timezone.utc
from uuid import uuid4

from app.ai.memory.ranking import MemoryRanker, MemoryScoredCandidate
from app.ai.memory.schemas import MemoryRead


def _memory(*, key: str, value: str, updated_at: datetime):
    return MemoryRead(
        id=uuid4(),
        user_id=uuid4(),
        key=key,
        value=value,
        source="chat",
        created_at=updated_at,
        updated_at=updated_at,
    )


def test_ranker_prefers_more_recent_memory_when_vector_scores_match():
    ranker = MemoryRanker()
    now = datetime.now(UTC)
    fresh = _memory(key="favorite_food", value="biryani", updated_at=now)
    stale = _memory(key="favorite_food", value="biryani", updated_at=now - timedelta(days=30))

    ranked = ranker.rank(
        "favorite food",
        [
            MemoryScoredCandidate(memory=stale, vector_distance=0.1),
            MemoryScoredCandidate(memory=fresh, vector_distance=0.1),
        ],
    )

    assert ranked[0].memory.id == fresh.id


def test_ranker_keeps_highest_score_for_duplicate_memory_candidates():
    ranker = MemoryRanker()
    now = datetime.now(UTC)
    memory = _memory(key="travel", value="goa", updated_at=now)

    ranked = ranker.rank(
        "travel goa",
        [
            MemoryScoredCandidate(memory=memory, vector_distance=0.9),
            MemoryScoredCandidate(memory=memory, vector_distance=0.1),
        ],
    )

    assert len(ranked) == 1
    assert ranked[0].vector_score > 0.8
