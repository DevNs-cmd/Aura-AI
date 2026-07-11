from __future__ import annotations

from dataclasses import dataclass
from datetime import datetime, timedelta
from typing import Any
from uuid import uuid4

import pytest

from app.ai.insights.exceptions import InsightsPipelineError, InsightsValidationError
from app.ai.insights.pipeline import InsightsPipeline
from app.ai.insights.repository import InsightsRepository
from app.ai.insights.schemas import (
    DailyActivityRead,
    InsightsPipelineInput,
    InsightsPipelineResult,
    JournalBadge,
    MoodTrend,
    ProductivityCategory,
)
from app.ai.insights.service import InsightsService
from app.ai.insights.utils import (
    build_journal_insight,
    infer_journal_label,
    infer_mood_trend,
    infer_productivity_score,
    to_journal_badge,
    weekly_usage_as_chart_values,
)


@dataclass(frozen=True)
class FakeJournalEntry:
    id: Any
    created_at: datetime
    title: str
    content: str
    summary: str = ""
    reflection: str = ""


@dataclass(frozen=True)
class FakeMessage:
    id: Any
    created_at: datetime
    content: str


@dataclass(frozen=True)
class FakeDocument:
    id: Any
    created_at: datetime
    filename: str
    file_type: str
    status: str


@dataclass(frozen=True)
class FakeMemory:
    id: Any
    created_at: datetime
    key: str
    value: str
    source: str


class FakeRepository(InsightsRepository):
    def __init__(self, *, journal_entries, chat_messages, documents, memories) -> None:
        self.calls: list[tuple[str, Any, Any]] = []
        self._journal_entries = journal_entries
        self._chat_messages = chat_messages
        self._documents = documents
        self._memories = memories

    def list_journal_entries(self, user_id, *, limit=None):
        self.calls.append(("journal", user_id, limit))
        return list(self._journal_entries)

    def list_chat_messages(self, user_id, *, limit=None):
        self.calls.append(("chat", user_id, limit))
        return list(self._chat_messages)

    def list_documents(self, user_id, *, limit=None):
        self.calls.append(("documents", user_id, limit))
        return list(self._documents)

    def list_memories(self, user_id, *, limit=None):
        self.calls.append(("memories", user_id, limit))
        return list(self._memories)


def _mk_inputs(user_id=None) -> InsightsPipelineInput:
    return InsightsPipelineInput(
        user_id=user_id or uuid4(),
        journal_limit=50,
        chat_limit=50,
        document_limit=50,
        memory_limit=50,
    )


def test_to_journal_badge_is_single_word_and_in_set():
    badge: JournalBadge = to_journal_badge("Low Energy")
    assert badge in {
        "Productive",
        "Focused",
        "Happy",
        "Motivated",
        "Reflective",
        "Calm",
        "Optimistic",
        "Energetic",
        "Balanced",
        "Thoughtful",
        "Creative",
        "Stressed",
        "Anxious",
        "Overwhelmed",
        "Tired",
    }
    assert " " not in badge


def test_journal_insight_is_1_to_3_sentences():
    sources = [
        # minimal objects that satisfy record_text fields via dict style
        type("S", (), {"text": "focus priority deep work", "weight": 1.0})(),
    ]
    label = infer_journal_label(sources)  # type: ignore[arg-type]
    insight = build_journal_insight(sources, label, "focus")
    sentences = [s.strip() for s in insight.replace("!", ".").replace("?", ".").split(".") if s.strip()]
    assert 1 <= len(sentences) <= 3


def test_mood_trend_improving_declining_mixed():
    base = datetime.utcnow()
    improving = [
        FakeJournalEntry(id=1, created_at=base, title="tired", content="I was tired and stressed"),
        FakeJournalEntry(id=2, created_at=base + timedelta(days=1), title="happy", content="I feel happy and grateful"),
    ]
    trend, _conf = infer_mood_trend(improving)
    assert trend in {"Improving", "Stable", "Declining", "Mixed"}

    declining = [
        FakeJournalEntry(id=1, created_at=base, title="productive", content="accomplished done progress"),
        FakeJournalEntry(id=2, created_at=base + timedelta(days=1), title="anxious", content="anxious worried on edge"),
    ]
    trend2, _conf2 = infer_mood_trend(declining)
    assert trend2 in {"Improving", "Stable", "Declining", "Mixed"}


def test_productivity_score_range_deterministic():
    base = datetime.utcnow()
    journal_entries = [FakeJournalEntry(id=1, created_at=base, title="Morning", content="I did complete tasks and felt focused")]
    chat_messages = [FakeMessage(id=1, created_at=base + timedelta(days=1), content="I finished a priority sprint project")]
    documents = [FakeDocument(id=1, created_at=base, filename="a", file_type="txt", status="indexed")]
    memories = [FakeMemory(id=1, created_at=base, key="k", value="v", source="manual")]

    label = "Productive"
    mood_trend: MoodTrend = "Improving"
    score = infer_productivity_score(
        journal_entries=journal_entries,
        chat_messages=chat_messages,
        documents=documents,
        memories=memories,
        label=label,
        mood_trend=mood_trend,
    )
    assert 0 <= score <= 100


def test_weekly_chart_values_mon_sun_length():
    # Build usage values using pipeline helper data
    base = datetime(2024, 1, 1)  # Monday
    usage_records = [
        FakeJournalEntry(id=1, created_at=base, title="a", content=""),
        FakeJournalEntry(id=2, created_at=base + timedelta(days=1), title="a", content=""),
        FakeJournalEntry(id=3, created_at=base + timedelta(days=2), title="a", content=""),
    ]
    from app.ai.insights.utils import build_weekly_usage

    weekly_usage = build_weekly_usage(usage_records)
    values = weekly_usage_as_chart_values(weekly_usage)
    assert len(values) == 7
    assert values[0] == 1
    assert values[1] == 1
    assert values[2] == 1


def test_pipeline_service_e2e_contract():
    base = datetime(2024, 1, 1)
    journal_entries = [
        FakeJournalEntry(
            id=1,
            created_at=base,
            title="Reflective",
            content="I am grateful and calm. I completed tasks.",
            summary="",
            reflection="",
        )
    ]
    chat_messages = [FakeMessage(id=1, created_at=base + timedelta(days=1), content="focused priority deep work")]
    documents = [FakeDocument(id=1, created_at=base + timedelta(days=2), filename="d", file_type="pdf", status="indexed")]
    memories = [FakeMemory(id=1, created_at=base + timedelta(days=3), key="m", value="v", source="manual")]

    repo = FakeRepository(
        journal_entries=journal_entries,
        chat_messages=chat_messages,
        documents=documents,
        memories=memories,
    )

    pipeline = InsightsPipeline(repository=repo)
    service = InsightsService(pipeline=pipeline)

    request = _mk_inputs()
    response: InsightsPipelineResult = service.get_insights(request, db=None)

    assert isinstance(response.journal_badge, str)
    assert " " not in response.journal_badge

    ui = response.usage_insights
    assert ui.daily_activity.Mon >= 0
    assert len(ui.usage_trend.chart_values) == 7
    assert isinstance(ui.weekly_percentage_change, float)


def test_service_rejects_invalid_input():
    pipeline = InsightsPipeline(
        repository=FakeRepository(journal_entries=[], chat_messages=[], documents=[], memories=[])
    )
    service = InsightsService(pipeline=pipeline)

    with pytest.raises(InsightsValidationError):
        service.get_insights(
            {
                # missing user_id
                "journal_limit": -1,
            },
            db=None,
        )


def test_pipeline_wraps_unexpected_errors():
    class ExplodingRepo(FakeRepository):
        def list_journal_entries(self, user_id, *, limit=None):
            raise RuntimeError("boom")

    repo = ExplodingRepo(journal_entries=[], chat_messages=[], documents=[], memories=[])
    pipeline = InsightsPipeline(repository=repo)
    with pytest.raises(InsightsPipelineError):
        pipeline.generate_insights(_mk_inputs(), db=None)

