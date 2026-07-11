from __future__ import annotations

from dataclasses import dataclass
from datetime import date, datetime, timedelta

from app.ai.notification.schemas import (
    NotificationCategory,
    NotificationItem,
    NotificationPriority,
)


NEGATIVE_MOODS = {"anxious", "sad", "frustrated"}


def priority_rank(priority: NotificationPriority) -> int:
    # lower rank sorts first
    if priority == NotificationPriority.HIGH:
        return 0
    if priority == NotificationPriority.MEDIUM:
        return 1
    return 2


def is_same_day(target: date, *, now: datetime) -> bool:
    return target == now.date()


def build_notification_id(*, category: NotificationCategory, title: str, scheduled_time: datetime | None, message: str) -> str:
    ts = scheduled_time.isoformat() if scheduled_time else "none"
    # Deterministic string id; stable across runs.
    return f"{category.value}|{title}|{ts}|{message}"


def sort_notifications(items: list[NotificationItem]) -> list[NotificationItem]:
    return sorted(
        items,
        key=lambda it: (
            priority_rank(it.priority),
            it.scheduled_time or datetime.max.replace(tzinfo=it.created_at.tzinfo),
            it.created_at,
            it.id,
        ),
    )


def deduplicate_notifications(items: list[NotificationItem], *, existing_ids: set[str]) -> list[NotificationItem]:
    out: list[NotificationItem] = []
    seen = set(existing_ids)
    for item in items:
        if item.id in seen:
            continue
        seen.add(item.id)
        out.append(item)
    return out


def build_upcoming_task_reminder(
    *,
    now: datetime,
    deadline: datetime,
) -> NotificationItem:
    scheduled_time = deadline - timedelta(minutes=10)
    expiry_time = scheduled_time + timedelta(minutes=5)
    title = "Upcoming Task"
    message = f"Project meeting starts in 10 minutes."
    created_at = now
    from app.ai.notification.schemas import NotificationCategory as Cat

    cat = Cat.TASK
    priority = NotificationPriority.MEDIUM
    notif_id = build_notification_id(
        category=cat,
        title=title,
        scheduled_time=scheduled_time,
        message=message,
    )
    return NotificationItem(
        id=notif_id,
        title=title,
        message=message,
        priority=priority,
        category=cat,
        scheduled_time=scheduled_time,
        expiry_time=expiry_time,
        created_at=created_at,
    )


def build_overdue_task(*, now: datetime, deadline: datetime) -> NotificationItem:
    title = "Task Overdue"
    message = "Your assignment deadline has passed."
    created_at = now
    cat = NotificationCategory.TASK
    priority = NotificationPriority.HIGH
    notif_id = build_notification_id(category=cat, title=title, scheduled_time=deadline, message=message)
    return NotificationItem(
        id=notif_id,
        title=title,
        message=message,
        priority=priority,
        category=cat,
        scheduled_time=deadline,
        expiry_time=None,
        created_at=created_at,
    )


def build_daily_journal_reminder(*, now: datetime) -> NotificationItem:
    title = "Daily Reflection"
    message = "Take a minute to record today's thoughts."
    cat = NotificationCategory.REMINDER
    priority = NotificationPriority.MEDIUM
    notif_id = build_notification_id(category=cat, title=title, scheduled_time=None, message=message)
    return NotificationItem(
        id=notif_id,
        title=title,
        message=message,
        priority=priority,
        category=cat,
        scheduled_time=now,
        expiry_time=now + timedelta(days=1),
        created_at=now,
    )


def build_productivity_alert(*, now: datetime) -> NotificationItem:
    title = "Stay Focused"
    message = "Your productivity has decreased today."
    cat = NotificationCategory.PRODUCTIVITY
    priority = NotificationPriority.MEDIUM
    notif_id = build_notification_id(category=cat, title=title, scheduled_time=None, message=message)
    return NotificationItem(
        id=notif_id,
        title=title,
        message=message,
        priority=priority,
        category=cat,
        scheduled_time=now,
        expiry_time=now + timedelta(hours=12),
        created_at=now,
    )


def build_mood_alert(*, now: datetime) -> NotificationItem:
    title = "Check In"
    message = "You've seemed stressed recently."
    cat = NotificationCategory.MOOD
    priority = NotificationPriority.MEDIUM
    notif_id = build_notification_id(category=cat, title=title, scheduled_time=None, message=message)
    return NotificationItem(
        id=notif_id,
        title=title,
        message=message,
        priority=priority,
        category=cat,
        scheduled_time=now,
        expiry_time=now + timedelta(hours=12),
        created_at=now,
    )


def build_achievement_notification(*, now: datetime, kind: str) -> NotificationItem:
    cat = NotificationCategory.ACHIEVEMENT
    if kind == "journal_streak":
        title = "Achievement Unlocked"
        message = "You've maintained a 7-day journal streak!"
        priority = NotificationPriority.LOW
        scheduled_time = now
    elif kind == "task_milestone":
        title = "Milestone Reached"
        message = "You reached a task milestone today."
        priority = NotificationPriority.LOW
        scheduled_time = now
    elif kind == "weekly_goal":
        title = "Weekly Goal Completed"
        message = "You completed your weekly goal."
        priority = NotificationPriority.LOW
        scheduled_time = now
    else:
        title = "Achievement"
        message = "You made progress!"
        priority = NotificationPriority.LOW
        scheduled_time = now

    notif_id = build_notification_id(category=cat, title=title, scheduled_time=scheduled_time, message=message)
    return NotificationItem(
        id=notif_id,
        title=title,
        message=message,
        priority=priority,
        category=cat,
        scheduled_time=scheduled_time,
        expiry_time=now + timedelta(days=7),
        created_at=now,
    )


def build_system_notification(*, now: datetime, announcement: dict) -> NotificationItem:
    cat = NotificationCategory.SYSTEM
    title = str(announcement.get("title") or "New Feature")
    message = str(announcement.get("message") or "")
    priority = NotificationPriority.HIGH
    notif_id = build_notification_id(category=cat, title=title, scheduled_time=None, message=message)
    return NotificationItem(
        id=notif_id,
        title=title,
        message=message,
        priority=priority,
        category=cat,
        scheduled_time=now,
        expiry_time=now + timedelta(days=30),
        created_at=now,
    )


def is_consistently_negative(*, moods: list[str], min_items: int = 3, ratio: float = 0.66) -> bool:
    if len(moods) < min_items:
        return False
    negative = sum(1 for m in moods[-min_items:] if m in NEGATIVE_MOODS)
    return (negative / min_items) >= ratio

