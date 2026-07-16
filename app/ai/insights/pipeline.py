from __future__ import annotations

from datetime import datetime
from typing import Any

from pydantic import ValidationError

from app.ai.insights.exceptions import (
    InsightsConfigurationError,
    InsightsError,
    InsightsPipelineError,
    InsightsValidationError,
)
from app.ai.insights.repository import InsightsRepository
from app.ai.insights.schemas import (
    InsightsPipelineInput,
    InsightsPipelineResult,
)

from app.ai.insights.utils import (
    InsightSource,
    build_journal_insight,
    build_weekly_usage,
    compute_weekly_percentage_change,
    infer_insight_theme,
    infer_journal_label,
    infer_mood_trend,
    infer_productivity_score,
    productivity_category,
    record_text,
    to_datetime,
    to_journal_badge,
    usage_trend_from_change,
    weekly_usage_as_chart_values,
)





class InsightsPipeline:
    def __init__(self, *, repository: InsightsRepository) -> None:
        self._repository = repository

    @staticmethod
    def _ensure_request(request: InsightsPipelineInput | dict[str, Any]) -> InsightsPipelineInput:
        if isinstance(request, InsightsPipelineInput):
            return request
        try:
            return InsightsPipelineInput.model_validate(request)
        except ValidationError as exc:
            raise InsightsValidationError("Invalid insights request") from exc

    def _load_sources(self, request: InsightsPipelineInput) -> tuple[list[Any], list[Any], list[Any], list[Any]]:
        journal_entries = self._repository.list_journal_entries(request.user_id, limit=request.journal_limit)
        chat_messages = self._repository.list_chat_messages(request.user_id, limit=request.chat_limit)
        documents = self._repository.list_documents(request.user_id, limit=request.document_limit)
        memories = self._repository.list_memories(request.user_id, limit=request.memory_limit)
        return journal_entries, chat_messages, documents, memories

    def _build_sources(
        self,
        journal_entries: list[Any],
        chat_messages: list[Any],
        documents: list[Any],
        memories: list[Any],
    ) -> list[InsightSource]:
        sources: list[InsightSource] = []
        ordered_journals = sorted(
            journal_entries,
            key=lambda entry: (
                to_datetime(getattr(entry, "created_at", None) if not isinstance(entry, dict) else entry.get("created_at"))
                or datetime.min,
                str(getattr(entry, "id", None) if not isinstance(entry, dict) else entry.get("id", "")),
            ),
        )

        if ordered_journals:
            latest_entry = ordered_journals[-1]
            sources.append(InsightSource(record_text(latest_entry, ("title", "content", "summary", "reflection")), 4.0))
        for entry in ordered_journals:
            sources.append(InsightSource(record_text(entry, ("title", "content", "summary", "reflection")), 2.0))
        for message in chat_messages:
            sources.append(InsightSource(record_text(message, ("content",)), 1.5))
        for document in documents:
            sources.append(InsightSource(record_text(document, ("filename", "file_type", "status")), 1.0))
        for memory in memories:
            sources.append(InsightSource(record_text(memory, ("key", "value", "source")), 1.0))

        return sources

    def _build_response(
        self,
        *,
        journal_entries: list[Any],
        chat_messages: list[Any],
        documents: list[Any],
        memories: list[Any],
    ) -> InsightsPipelineResult:
        sources = self._build_sources(journal_entries, chat_messages, documents, memories)

        # Usage/activity chart values (Mon-Sun)
        weekly_usage = build_weekly_usage([*journal_entries, *chat_messages, *documents, *memories])
        chart_values = weekly_usage_as_chart_values(weekly_usage)
        weekly_percentage_change = compute_weekly_percentage_change(weekly_usage)
        usage_trend = usage_trend_from_change(weekly_percentage_change)

        # Journal insight + badge
        journal_label = infer_journal_label(sources)
        journal_badge = to_journal_badge(journal_label)
        insight_theme = infer_insight_theme(sources)
        journal_insight = build_journal_insight(sources, journal_label, insight_theme)

        # Mood and productivity
        mood_trend, _confidence = infer_mood_trend(journal_entries)
        productivity_score = infer_productivity_score(
            journal_entries=journal_entries,
            chat_messages=chat_messages,
            documents=documents,
            memories=memories,
            label=journal_label,
            mood_trend=mood_trend,
        )

        return InsightsPipelineResult(
            journal_badge=journal_badge,
            journal_insight=journal_insight,
            usage_insights={
                "daily_activity": weekly_usage.model_dump(),
                "weekly_productivity": {
                    "score": productivity_score,
                    "category": productivity_category(productivity_score),
                },
                "mood_trend": mood_trend,
                "usage_trend": {"trend": usage_trend, "chart_values": chart_values},
                "weekly_percentage_change": float(weekly_percentage_change),
            },
        )


    def generate_insights(
        self,
        request: InsightsPipelineInput | dict[str, Any],
        db: Any | None = None,
    ) -> InsightsPipelineResult:
        del db
        insights_request = self._ensure_request(request)
        try:
            journal_entries, chat_messages, documents, memories = self._load_sources(insights_request)
            return self._build_response(
                journal_entries=journal_entries,
                chat_messages=chat_messages,
                documents=documents,
                memories=memories,
            )
        except InsightsError:
            raise
        except Exception as exc:  # noqa: BLE001 - orchestration boundary
            raise InsightsPipelineError("Failed to generate insights") from exc

    def get_insights(
        self,
        request: InsightsPipelineInput | dict[str, Any],
        db: Any | None = None,
    ) -> InsightsPipelineResult:
        return self.generate_insights(request=request, db=db)


def build_insights_pipeline(*, repository: InsightsRepository | None = None) -> InsightsPipeline:
    if repository is None:
        raise InsightsConfigurationError("An insights repository is required to build the insights pipeline")
    return InsightsPipeline(repository=repository)
