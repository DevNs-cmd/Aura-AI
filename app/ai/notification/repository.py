from __future__ import annotations

from dataclasses import dataclass
from datetime import date, datetime
from typing import Any

from app.ai.notification.schemas import NotificationRequest


@dataclass(frozen=True)
class NotificationData:
    now: datetime
    upcoming_task_deadlines: list[datetime]
    overdue_task_deadline: datetime | None
    journal_entry_dates: list[date]
    recent_journal_moods: list[str]
    productivity_score_today: float | None
    productivity_drop_threshold: float
    journal_streak_days: int | None
    task_milestone_reached: bool
    weekly_goal_completed: bool
    app_announcement: dict[str, Any] | None
    already_sent_notification_ids: list[str]


class NotificationRepository:
    """Repository that retrieves only the required datasets.

    In this repo, persistence is outside of scope; therefore this repository
    simply provides access to the provided input datasets.
    """

    def __init__(self, *, request: NotificationRequest):
        self._request = request

    def get_data(self) -> NotificationData:
        return NotificationData(
            now=self._request.now,
            upcoming_task_deadlines=list(self._request.upcoming_task_deadlines),
            overdue_task_deadline=self._request.overdue_task_deadline,
            journal_entry_dates=list(self._request.journal_entry_dates),
            recent_journal_moods=list(self._request.recent_journal_moods),
            productivity_score_today=self._request.productivity_score_today,
            productivity_drop_threshold=self._request.productivity_drop_threshold,
            journal_streak_days=self._request.journal_streak_days,
            task_milestone_reached=self._request.task_milestone_reached,
            weekly_goal_completed=self._request.weekly_goal_completed,
            app_announcement=self._request.app_announcement,
            already_sent_notification_ids=list(self._request.already_sent_notification_ids),
        )

