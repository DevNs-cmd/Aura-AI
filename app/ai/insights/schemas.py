from __future__ import annotations

from typing import Any, Literal
from uuid import UUID

from pydantic import BaseModel, ConfigDict, Field


# Journal badge must be exactly one word from this set.
JournalBadge = Literal[
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
    "Motivated",
    "Stressed",
    "Anxious",
    "Overwhelmed",
    "Tired",
]

# Backwards-compatible label type used internally for insight/recommendations.
JournalLabel = Literal[
    "Productive",
    "Focused",
    "Happy",
    "Motivated",
    "Reflective",
    "Calm",
    "Optimistic",
    "Confident",
    "Excited",
    "Creative",
    "Relaxed",
    "Balanced",
    "Hopeful",
    "Grateful",
    "Energetic",
    "Busy",
    "Overwhelmed",
    "Stressed",
    "Anxious",
    "Burnout Risk",
    "Tired",
    "Frustrated",
    "Distracted",
    "Low Energy",
]


MoodTrend = Literal["Improving", "Stable", "Declining", "Mixed"]
ProductivityCategory = Literal["Low", "Moderate", "High", "Excellent"]


class WeeklyUsageRead(BaseModel):
    model_config = ConfigDict(extra="forbid")

    Mon: int = Field(default=0, ge=0)
    Tue: int = Field(default=0, ge=0)
    Wed: int = Field(default=0, ge=0)
    Thu: int = Field(default=0, ge=0)
    Fri: int = Field(default=0, ge=0)
    Sat: int = Field(default=0, ge=0)
    Sun: int = Field(default=0, ge=0)


class InsightsRequest(BaseModel):
    model_config = ConfigDict(extra="forbid")

    user_id: UUID | str
    journal_limit: int = Field(default=50, ge=0)
    chat_limit: int = Field(default=200, ge=0)
    document_limit: int = Field(default=20, ge=0)
    memory_limit: int = Field(default=50, ge=0)


class DailyActivityRead(BaseModel):
    model_config = ConfigDict(extra="forbid")

    Mon: int = Field(default=0, ge=0)
    Tue: int = Field(default=0, ge=0)
    Wed: int = Field(default=0, ge=0)
    Thu: int = Field(default=0, ge=0)
    Fri: int = Field(default=0, ge=0)
    Sat: int = Field(default=0, ge=0)
    Sun: int = Field(default=0, ge=0)


class WeeklyProductivityRead(BaseModel):
    model_config = ConfigDict(extra="forbid")

    score: int = Field(ge=0, le=100)
    category: ProductivityCategory


class UsageTrendRead(BaseModel):
    model_config = ConfigDict(extra="forbid")

    trend: MoodTrend
    # Deterministic numeric series aligned with chart_values (Mon-Sun)
    chart_values: list[int] = Field(min_length=7, max_length=7)


class UsageInsightsRead(BaseModel):
    model_config = ConfigDict(extra="forbid")

    daily_activity: DailyActivityRead
    weekly_productivity: WeeklyProductivityRead
    mood_trend: MoodTrend
    usage_trend: UsageTrendRead
    weekly_percentage_change: float


class InsightsResponse(BaseModel):
    model_config = ConfigDict(extra="forbid", from_attributes=True)

    journal_badge: JournalBadge
    journal_insight: str = Field(min_length=1, max_length=500)

    # Usage insights for Profile screen (backend-only structured payload)
    usage_insights: UsageInsightsRead


class InsightsPipelineInput(InsightsRequest):
    model_config = ConfigDict(extra="forbid")


# Pipeline result is identical to the response contract.
InsightsPipelineResult = InsightsResponse


InsightsRequestPayload = InsightsRequest
InsightsResponsePayload = InsightsResponse



