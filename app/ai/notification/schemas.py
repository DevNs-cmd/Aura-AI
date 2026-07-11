from __future__ import annotations

from datetime import date, datetime
from enum import Enum
from typing import Any

from pydantic import BaseModel, ConfigDict, Field


class NotificationPriority(str, Enum):
    HIGH = "HIGH"
    MEDIUM = "MEDIUM"
    LOW = "LOW"


class NotificationCategory(str, Enum):
    TASK = "TASK"
    REMINDER = "REMINDER"
    PRODUCTIVITY = "PRODUCTIVITY"
    MOOD = "MOOD"
    ACHIEVEMENT = "ACHIEVEMENT"
    SYSTEM = "SYSTEM"


class NotificationItem(BaseModel):
    id: str
    title: str
    message: str
    priority: NotificationPriority
    category: NotificationCategory
    scheduled_time: datetime | None = None
    expiry_time: datetime | None = None
    created_at: datetime


class NotificationResponse(BaseModel):
    items: list[NotificationItem] = Field(default_factory=list)
    created_at: datetime


class NotificationRequest(BaseModel):
    """Deterministic input to the notification engine."""

    now: datetime
    user_id: str | None = None

    # Task-related
    upcoming_task_deadlines: list[datetime] = Field(default_factory=list)
    overdue_task_deadline: datetime | None = None

    # Journal-related
    journal_entry_dates: list[date] = Field(default_factory=list)
    recent_journal_moods: list[str] = Field(default_factory=list)

    # Productivity
    productivity_score_today: float | None = None
    productivity_drop_threshold: float = 0.5

    # Achievement
    journal_streak_days: int | None = None
    task_milestone_reached: bool = False
    weekly_goal_completed: bool = False

    # App / system announcements
    app_announcement: dict[str, Any] | None = None

    # Dedup
    already_sent_notification_ids: list[str] = Field(default_factory=list)

    model_config = ConfigDict(extra="forbid")

