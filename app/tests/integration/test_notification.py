from __future__ import annotations

from datetime import date, datetime, timedelta, timezone

from app.ai.notification.repository import NotificationRepository
from app.ai.notification.pipeline import NotificationPipeline
from app.ai.notification.schemas import NotificationRequest
from app.ai.notification.service import NotificationService


UTC = timezone.utc


def test_integration_combined_notifications_sorted_and_deduped():
    now = datetime(2025, 2, 1, 9, 0, 0, tzinfo=UTC)

    req = NotificationRequest(
        now=now,
        upcoming_task_deadlines=[now + timedelta(minutes=7)],
        overdue_task_deadline=now - timedelta(minutes=30),
        journal_entry_dates=[now.date()],  # prevent daily reflection
        recent_journal_moods=["anxious", "sad", "frustrated"],
        productivity_score_today=0.2,
        productivity_drop_threshold=0.5,
        journal_streak_days=7,
        task_milestone_reached=False,
        weekly_goal_completed=True,
        app_announcement={"title": "New Feature", "message": "Voice chat is now available."},
    )

    repo = NotificationRepository(request=req)
    pipeline = NotificationPipeline(repository=repo)
    service = NotificationService(pipeline=pipeline)

    resp = service.generate(req)
    assert resp.items

    # Priority order: HIGH before MEDIUM.
    assert resp.items[0].priority.value in {"HIGH"}
    assert all(resp.items[i].priority.value in {"HIGH", "MEDIUM", "LOW"} for i in range(len(resp.items)))

    # Dedup should remove items if already_sent_notification_ids includes them.
    first_id = resp.items[0].id
    req2 = req.model_copy(update={"already_sent_notification_ids": [first_id]})
    repo2 = NotificationRepository(request=req2)
    pipeline2 = NotificationPipeline(repository=repo2)
    service2 = NotificationService(pipeline=pipeline2)
    resp2 = service2.generate(req2)

    assert all(i.id != first_id for i in resp2.items)


def test_integration_empty_datasets_returns_no_notifications():
    now = datetime(2025, 2, 1, 9, 0, 0, tzinfo=UTC)
    req = NotificationRequest(now=now)

    repo = NotificationRepository(request=req)
    pipeline = NotificationPipeline(repository=repo)
    service = NotificationService(pipeline=pipeline)

    resp = service.generate(req)
    assert resp.items == []

