from __future__ import annotations

from datetime import datetime, timedelta

from app.ai.notification.exceptions import NotificationPipelineError
from app.ai.notification.repository import NotificationRepository
from app.ai.notification.schemas import (
    NotificationCategory,
    NotificationPriority,
    NotificationRequest,
    NotificationResponse,
)
from app.ai.notification.utils import (
    build_daily_journal_reminder,
    build_mood_alert,
    build_overdue_task,
    build_productivity_alert,
    build_achievement_notification,
    build_system_notification,
    build_upcoming_task_reminder,
    deduplicate_notifications,
    is_consistently_negative,
    is_same_day,
    sort_notifications,
)


class NotificationPipeline:
    def __init__(self, *, repository: NotificationRepository):
        self.repository = repository

    @staticmethod
    def _upcoming_within_window(now: datetime, deadline: datetime, *, lead_minutes: int = 10) -> bool:
        # Deterministic window: schedule only when deadline-now is within [lead_minutes, lead_minutes+0]??
        # Requirement: notify 5–10 minutes before. We'll interpret as: if deadline is exactly 5..10 minutes away.
        delta = deadline - now
        minutes = delta.total_seconds() / 60.0
        return 5.0 <= minutes <= 10.0

    def run(self, request: NotificationRequest) -> NotificationResponse:
        try:
            data = self.repository.get_data()
            now = data.now

            items = []

            # 1) Upcoming Task Reminder (5-10 minutes)
            for deadline in data.upcoming_task_deadlines:
                if self._upcoming_within_window(now, deadline):
                    items.append(build_upcoming_task_reminder(now=now, deadline=deadline))

            # 2) Overdue Task
            if data.overdue_task_deadline is not None:
                items.append(build_overdue_task(now=now, deadline=data.overdue_task_deadline))

            # 3) Daily Journal Reminder only if no journal entry exists today.
            # If caller did not provide journal dates, treat as "journal unknown" and skip.
            if data.journal_entry_dates:
                has_today = any(is_same_day(d, now=now) for d in data.journal_entry_dates)
                if not has_today:
                    items.append(build_daily_journal_reminder(now=now))


            # 4) Productivity Alert
            if data.productivity_score_today is not None and data.productivity_score_today < data.productivity_drop_threshold:
                items.append(build_productivity_alert(now=now))

            # 5) Mood Alert if recent journal mood consistently negative
            if is_consistently_negative(moods=data.recent_journal_moods):
                items.append(build_mood_alert(now=now))

            # 6) Achievement notifications
            if data.journal_streak_days is not None and data.journal_streak_days >= 7:
                items.append(build_achievement_notification(now=now, kind="journal_streak"))
            if data.task_milestone_reached:
                items.append(build_achievement_notification(now=now, kind="task_milestone"))
            if data.weekly_goal_completed:
                items.append(build_achievement_notification(now=now, kind="weekly_goal"))

            # 7) App Update / System announcement
            if data.app_announcement is not None:
                items.append(build_system_notification(now=now, announcement=data.app_announcement))

            # Dedup + sort
            existing_ids = set(data.already_sent_notification_ids)
            items = deduplicate_notifications(items, existing_ids=existing_ids)
            items = sort_notifications(items)

            return NotificationResponse(items=items, created_at=now)
        except Exception as exc:
            raise NotificationPipelineError("Failed to generate notifications") from exc

