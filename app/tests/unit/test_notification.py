from __future__ import annotations

from datetime import date, datetime, timedelta, timezone

import pytest

from app.ai.notification.schemas import (
    NotificationCategory,
    NotificationPriority,
    NotificationRequest,
)
from app.ai.notification.service import build_notification_service


UTC = timezone.utc


def dt(minutes: int = 0) -> datetime:
    return datetime(2025, 1, 1, 12, 0, 0, tzinfo=UTC) + timedelta(minutes=minutes)


def test_upcoming_task_reminder():
    now = dt(0)
    deadline = dt(10)
    service = build_notification_service()

    resp = service.generate(
        NotificationRequest(
            now=now,
            upcoming_task_deadlines=[deadline],
        )
    )

    assert len(resp.items) == 1
    item = resp.items[0]
    assert item.title == "Upcoming Task"
    assert item.category == NotificationCategory.TASK
    assert item.message == "Project meeting starts in 10 minutes."


def test_overdue_task():
    now = dt(0)
    deadline = dt(-1)
    service = build_notification_service()

    resp = service.generate(
        NotificationRequest(now=now, overdue_task_deadline=deadline)
    )

    assert len(resp.items) == 1
    item = resp.items[0]
    assert item.title == "Task Overdue"
    assert item.priority == NotificationPriority.HIGH


def test_daily_journal_reminder_only_if_no_entry_today():
    now = dt(0)
    service = build_notification_service()

    # Case: no entry today
    resp1 = service.generate(
        NotificationRequest(now=now, journal_entry_dates=[date(2024, 12, 31)])
    )
    assert any(i.title == "Daily Reflection" for i in resp1.items)

    # Case: entry exists today
    resp2 = service.generate(
        NotificationRequest(now=now, journal_entry_dates=[now.date()])
    )
    assert not any(i.title == "Daily Reflection" for i in resp2.items)


def test_productivity_alert_when_below_threshold():
    now = dt(0)
    service = build_notification_service()

    resp = service.generate(
        NotificationRequest(
            now=now,
            productivity_score_today=0.1,
            productivity_drop_threshold=0.5,
        )
    )

    assert len(resp.items) == 1
    assert resp.items[0].title == "Stay Focused"


def test_mood_alert_when_consistently_negative():
    now = dt(0)
    service = build_notification_service()

    resp = service.generate(
        NotificationRequest(
            now=now,
            recent_journal_moods=["neutral", "anxious", "sad", "frustrated"],
        )
    )

    assert any(i.title == "Check In" for i in resp.items)


def test_achievement_notification_journal_streak_task_milestone_weekly_goal():
    now = dt(0)
    service = build_notification_service()

    resp = service.generate(
        NotificationRequest(
            now=now,
            journal_streak_days=7,
            task_milestone_reached=True,
            weekly_goal_completed=True,
        )
    )

    titles = {i.title for i in resp.items}
    assert "Achievement Unlocked" in titles
    assert "Milestone Reached" in titles
    assert "Weekly Goal Completed" in titles


def test_system_notification_app_announcement():
    now = dt(0)
    service = build_notification_service()

    resp = service.generate(
        NotificationRequest(
            now=now,
            app_announcement={"title": "New Feature", "message": "Voice chat is now available."},
        )
    )

    assert len(resp.items) == 1
    item = resp.items[0]
    assert item.category == NotificationCategory.SYSTEM
    assert item.title == "New Feature"
    assert item.message == "Voice chat is now available."
    assert item.priority == NotificationPriority.HIGH


def test_priority_ordering_and_deduplication():
    now = dt(0)
    service = build_notification_service()

    resp = service.generate(
        NotificationRequest(
            now=now,
            overdue_task_deadline=dt(-1),  # HIGH
            productivity_score_today=0.1,  # MEDIUM
            productivity_drop_threshold=0.5,
            already_sent_notification_ids=[],
        )
    )

    assert len(resp.items) == 2
    assert resp.items[0].priority == NotificationPriority.HIGH
    assert resp.items[1].priority == NotificationPriority.MEDIUM

    # Dedup: send again with the known id of overdue task.
    overdue_id = resp.items[0].id
    resp2 = service.generate(
        NotificationRequest(
            now=now,
            overdue_task_deadline=dt(-1),
            productivity_score_today=0.1,
            productivity_drop_threshold=0.5,
            already_sent_notification_ids=[overdue_id],
        )
    )
    assert len(resp2.items) == 1
    assert resp2.items[0].title == "Stay Focused"


def test_empty_input_returns_empty_items():
    now = dt(0)
    service = build_notification_service()

    resp = service.generate(NotificationRequest(now=now))
    assert resp.items == []

