from __future__ import annotations

import re
from dataclasses import dataclass
from datetime import datetime
from typing import Any, Iterable, Sequence

from app.ai.insights.schemas import (
    JournalBadge,
    WeeklyUsageRead,
)


WEEKDAY_KEYS = ("Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun")
WEEKDAY_BY_INDEX = {index: key for index, key in enumerate(WEEKDAY_KEYS)}

TOKEN_RE = re.compile(r"[A-Za-z0-9_']+")

LABEL_KEYWORDS: dict[str, tuple[str, ...]] = {
    "Productive": ("productive", "accomplished", "completed", "finished", "efficient", "delivered", "resolved", "checked off"),
    "Focused": ("focused", "focus", "deep work", "concentrated", "uninterrupted", "priority", "sprint"),
    "Happy": ("happy", "joyful", "joy", "glad", "delighted", "cheerful"),
    "Motivated": ("motivated", "driven", "inspired", "determined", "ready to go"),
    "Reflective": ("reflective", "reflect", "thoughtful", "processing", "considering", "learning"),
    "Calm": ("calm", "peaceful", "steady", "grounded", "centered", "composed"),
    "Optimistic": ("optimistic", "positive", "bright", "encouraged", "upbeat"),
    "Confident": ("confident", "capable", "assured", "certain", "self-assured"),
    "Excited": ("excited", "eager", "thrilled", "energized", "enthusiastic"),
    "Creative": ("creative", "creativity", "ideas", "brainstorm", "imaginative", "inventive"),
    "Relaxed": ("relaxed", "rested", "ease", "unwound", "laid back"),
    "Balanced": ("balanced", "steady rhythm", "stable", "routine", "aligned", "even"),
    "Hopeful": ("hopeful", "hope", "encouraged", "looking forward", "possibility"),
    "Grateful": ("grateful", "gratitude", "thankful", "appreciative"),
    "Energetic": ("energetic", "energized", "lively", "active", "vibrant"),
    "Busy": ("busy", "packed", "full day", "swamped", "lots going on"),
    "Overwhelmed": ("overwhelmed", "overload", "too much", "swamped", "buried"),
    "Stressed": ("stressed", "stress", "pressure", "tense", "strain"),
    "Anxious": ("anxious", "worried", "nervous", "uneasy", "on edge"),
    "Burnout Risk": ("burnout", "burnt out", "exhausted", "drained", "depleted", "can't keep up"),
    "Tired": ("tired", "sleepy", "fatigued", "worn out", "low energy"),
    "Frustrated": ("frustrated", "annoyed", "irritated", "stuck", "blocked"),
    "Distracted": ("distracted", "scattered", "sidetracked", "unfocused", "pulled away"),
    "Low Energy": ("low energy", "sluggish", "weary", "flat", "drained"),
}

LABEL_PRIORITY = [
    "Burnout Risk",
    "Overwhelmed",
    "Stressed",
    "Anxious",
    "Tired",
    "Low Energy",
    "Frustrated",
    "Distracted",
    "Productive",
    "Focused",
    "Motivated",
    "Creative",
    "Happy",
    "Calm",
    "Optimistic",
    "Confident",
    "Excited",
    "Relaxed",
    "Balanced",
    "Hopeful",
    "Grateful",
    "Energetic",
    "Busy",
    "Reflective",
]

POSITIVE_WORDS = {
    "accomplished",
    "achieved",
    "calm",
    "complete",
    "completed",
    "confident",
    "consistent",
    "creative",
    "done",
    "energized",
    "focused",
    "grateful",
    "happy",
    "hopeful",
    "improving",
    "inspired",
    "motivated",
    "productive",
    "progress",
    "relaxed",
    "steady",
    "successful",
    "supported",
}

NEGATIVE_WORDS = {
    "anxious",
    "burnout",
    "drained",
    "exhausted",
    "frustrated",
    "overwhelmed",
    "pressure",
    "scattered",
    "stressed",
    "tired",
    "uneasy",
    "worn",
    "worried",
}

FOCUS_WORDS = {
    "focused",
    "focus",
    "deep work",
    "priority",
    "priorities",
    "block",
    "uninterrupted",
    "concentrated",
    "concentration",
}

COMPLETION_WORDS = {
    "accomplished",
    "achieved",
    "checked off",
    "completed",
    "done",
    "finished",
    "resolved",
    "shipped",
    "wrapped up",
}

RECOVERY_WORDS = {
    "break",
    "breathe",
    "pause",
    "rest",
    "recover",
    "recharge",
    "sleep",
    "walk",
    "slow down",
}

CREATIVE_WORDS = {
    "brainstorm",
    "creative",
    "design",
    "ideas",
    "imaginative",
    "inventive",
    "write",
    "sketch",
}

NEGATIVE_TONE_WORDS = NEGATIVE_WORDS | {
    "busy",
    "crammed",
    "full",
    "late",
    "rush",
}


@dataclass(frozen=True)
class InsightSource:
    text: str
    weight: float = 1.0


def normalize_text(value: Any) -> str | None:
    if value is None:
        return None
    text = str(value).strip()
    return text or None


def get_value(record: Any, field: str, default: Any = None) -> Any:
    if isinstance(record, dict):
        return record.get(field, default)
    return getattr(record, field, default)


def to_datetime(value: Any) -> datetime | None:
    if value is None:
        return None
    if isinstance(value, datetime):
        return value
    try:
        return datetime.fromisoformat(str(value))
    except ValueError:
        return None


def record_text(record: Any, fields: Sequence[str]) -> str:
    parts: list[str] = []
    for field in fields:
        cleaned = normalize_text(get_value(record, field))
        if cleaned:
            parts.append(cleaned)
    return " ".join(parts)


def token_count(text: str) -> int:
    return len(TOKEN_RE.findall(text.lower()))


def count_phrase(text: str, phrase: str) -> int:
    haystack = text.lower()
    needle = phrase.lower().strip()
    if not needle:
        return 0
    if " " in needle:
        return haystack.count(needle)
    return len(re.findall(rf"\b{re.escape(needle)}\b", haystack))


def count_any(text: str, phrases: Iterable[str]) -> int:
    return sum(count_phrase(text, phrase) for phrase in phrases)


def combine_sources(sources: Iterable[InsightSource]) -> str:
    pieces: list[str] = []
    for source in sources:
        cleaned = normalize_text(source.text)
        if not cleaned:
            continue
        repeat = max(int(round(source.weight)), 1)
        pieces.extend([cleaned] * repeat)
    return "\n".join(pieces)


def build_weekly_usage(records: Iterable[Any]) -> WeeklyUsageRead:
    counts = {key: 0 for key in WEEKDAY_KEYS}
    for record in records:
        created_at = to_datetime(get_value(record, "created_at"))
        if created_at is None:
            continue
        counts[WEEKDAY_BY_INDEX[created_at.weekday()]] += 1
    return WeeklyUsageRead(**counts)


def weekly_usage_as_chart_values(usage: WeeklyUsageRead) -> list[int]:
    m = usage.model_dump()
    return [m[d] for d in WEEKDAY_KEYS]


def compute_weekly_percentage_change(usage: WeeklyUsageRead) -> float:
    """Percent change from weekday to weekend totals."""

    m = usage.model_dump()
    weekday_total = m["Mon"] + m["Tue"] + m["Wed"] + m["Thu"]
    weekend_total = m["Fri"] + m["Sat"] + m["Sun"]

    if weekday_total == 0:
        return 0.0 if weekend_total == 0 else 1.0
    return (weekend_total - weekday_total) / float(weekday_total)



def weekly_usage_as_dict(usage: WeeklyUsageRead) -> dict[str, int]:
    return usage.model_dump()


def compute_weekly_change(usage: WeeklyUsageRead) -> str:
    usage_map = usage.model_dump()
    weekday_total = usage_map["Mon"] + usage_map["Tue"] + usage_map["Wed"] + usage_map["Thu"]
    weekend_total = usage_map["Fri"] + usage_map["Sat"] + usage_map["Sun"]
    return f"{weekend_total - weekday_total:+d}"


def summarize_weekly_usage(usage: WeeklyUsageRead) -> str:
    usage_map = usage.model_dump()
    ordered = [(day, usage_map[day]) for day in WEEKDAY_KEYS]
    top_day, top_count = max(ordered, key=lambda item: (item[1], -WEEKDAY_KEYS.index(item[0])))
    weekday_total = usage_map["Mon"] + usage_map["Tue"] + usage_map["Wed"] + usage_map["Thu"]
    weekend_total = usage_map["Fri"] + usage_map["Sat"] + usage_map["Sun"]

    if top_count == 0:
        return "Activity was evenly quiet across the week."
    if weekend_total > weekday_total + 2:
        return "Your activity increased steadily during the weekend."
    if weekday_total > weekend_total + 2:
        return "Your activity was stronger earlier in the week."
    return f"You were most active on {top_day}."


def _score_label(text: str, label: str) -> int:
    keywords = LABEL_KEYWORDS[label]
    score = 0
    for keyword in keywords:
        score += count_phrase(text, keyword)
    return score


def infer_journal_label(sources: Iterable[InsightSource]) -> str:
    text = combine_sources(sources).lower()
    if not text:
        return "Reflective"

    scores = {label: _score_label(text, label) for label in LABEL_KEYWORDS}
    best_score = max(scores.values()) if scores else 0
    if best_score == 0:
        completion_hits = count_any(text, COMPLETION_WORDS)
        focus_hits = count_any(text, FOCUS_WORDS)
        negative_hits = count_any(text, NEGATIVE_TONE_WORDS)
        if negative_hits >= 3:
            return "Stressed"
        if completion_hits > 0:
            return "Productive"
        if focus_hits > 0:
            return "Focused"
        if token_count(text) > 120:
            return "Busy"
        return "Reflective"

    best_labels = [label for label, score in scores.items() if score == best_score]
    best_labels.sort(key=lambda label: LABEL_PRIORITY.index(label))
    return best_labels[0]


def to_journal_badge(label: str) -> JournalBadge:
    """Map internal labels (may include multi-word) to a single-word badge."""

    mapping: dict[str, JournalBadge] = {
        "Burnout Risk": "Overwhelmed",
        "Low Energy": "Tired",
    }

    badge_set = {
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

    if label in badge_set:
        return label  # type: ignore[return-value]

    mapped = mapping.get(label)
    if mapped is not None:
        return mapped

    # Fallback based on deterministic keyword presence.
    return "Tired" if any(
        w in label.lower() for w in ("tired", "low", "burn", "drained", "exhaust")
    ) else "Reflective"



def infer_insight_theme(sources: Iterable[InsightSource]) -> str:
    text = combine_sources(sources).lower()
    theme_scores = {
        "focus": count_any(text, FOCUS_WORDS) + count_any(text, COMPLETION_WORDS),
        "recovery": count_any(text, RECOVERY_WORDS),
        "creative": count_any(text, CREATIVE_WORDS),
        "positive": sum(text.count(word) for word in POSITIVE_WORDS),
        "pressure": count_any(text, NEGATIVE_TONE_WORDS),
    }
    best_theme, best_score = max(theme_scores.items(), key=lambda item: (item[1], item[0]))
    return best_theme if best_score > 0 else "steady"


def build_journal_insight(sources: Iterable[InsightSource], label: str, theme: str) -> str:
    _text = combine_sources(sources).lower()

    def _sentences(s: str) -> list[str]:
        parts = [p.strip() for p in s.replace("!", ".").replace("?", ".").split(".")]
        return [p for p in parts if p]

    def _limit(s: str) -> str:
        sents = _sentences(s)
        return ". ".join(sents[:3]) + ("." if sents else "")

    if theme == "focus":
        return _limit(
            "You seem to do your best when you have a clear priority. "
            "Protect one uninterrupted focus block tomorrow so important work gets your best energy."
        )

    if theme == "recovery":
        return _limit(
            "Your week looks full, so small recovery breaks will help you stay steady. "
            "Try pausing after long sessions and give yourself a short reset before the next task."
        )

    if theme == "creative":
        return _limit(
            "Your notes suggest creative momentum and fresh ideas. "
            "Capture them quickly, then set aside one small block to turn the strongest idea into progress."
        )
    if theme == "pressure":
        return _limit(
            "You have a lot in motion right now, but the overall pattern still shows commitment. "
            "Narrow tomorrow to one main priority and let a short break help you keep the day manageable."
        )
    if label in {"Calm", "Balanced", "Reflective", "Hopeful", "Grateful"}:
        return _limit(
            "Your activity suggests a steady and reflective rhythm. "
            "Keep using that calm momentum by reviewing what worked and choosing one next step for tomorrow."
        )
    if label in {"Productive", "Focused", "Motivated", "Confident", "Energetic"}:
        return _limit(
            "Your pattern shows strong momentum and follow-through. "
            "Keep protecting the time that helps you start quickly so the productive streak stays easy to repeat."
        )
    if label in {"Overwhelmed", "Stressed", "Anxious", "Burnout Risk", "Tired", "Low Energy"}:
        return _limit(
            "The week appears demanding, but you are still moving through it with intention. "
            "Trim tomorrow to one practical priority and add a short recovery break so your energy has room to recover."
        )
    return _limit(
        "Your activity suggests steady progress across journaling, chat, and your daily tasks. "
        "Keep one small focus block in place so momentum stays manageable and supportive."
    )



def _entry_valence(text: str) -> int:
    positive = count_any(text, POSITIVE_WORDS)
    negative = count_any(text, NEGATIVE_WORDS)
    return positive - negative


def infer_mood_trend(journal_entries: Sequence[Any]) -> tuple[str, float]:
    if not journal_entries:
        return "Mixed", 0.2

    ordered = sorted(
        journal_entries,
        key=lambda entry: (
            to_datetime(get_value(entry, "created_at")) or datetime.min,
            str(get_value(entry, "id", "")),
        ),
    )
    scores = [
        _entry_valence(record_text(entry, ("title", "content", "summary", "reflection")))
        for entry in ordered
    ]

    if len(scores) == 1:
        score = scores[0]
        if score > 0:
            return "Stable", 0.55
        if score < 0:
            return "Mixed", 0.45
        return "Stable", 0.35

    midpoint = max(len(scores) // 2, 1)
    first_half = scores[:midpoint]
    second_half = scores[midpoint:]
    early_average = sum(first_half) / max(len(first_half), 1)
    recent_average = sum(second_half) / max(len(second_half), 1)
    difference = recent_average - early_average
    spread = max(scores) - min(scores)
    mixed_signal = any(score > 0 for score in scores) and any(score < 0 for score in scores)

    if difference >= 0.75:
        trend = "Improving"
    elif difference <= -0.75:
        trend = "Declining"
    elif mixed_signal and spread >= 2:
        trend = "Mixed"
    else:
        trend = "Stable"

    confidence = 0.35 + min(len(scores), 8) * 0.06 + min(abs(difference), 4.0) * 0.08
    if trend == "Mixed":
        confidence -= 0.05
    confidence = max(0.15, min(confidence, 0.95))
    return trend, round(confidence, 2)


def infer_productivity_score(
    *,
    journal_entries: Sequence[Any],
    chat_messages: Sequence[Any],
    documents: Sequence[Any],
    memories: Sequence[Any],
    label: str,
    mood_trend: str,
) -> int:
    corpus = combine_sources(
        [
            InsightSource(record_text(entry, ("title", "content", "summary", "reflection")), 1.0)
            for entry in journal_entries
        ]
        + [
            InsightSource(record_text(message, ("content",)), 0.8)
            for message in chat_messages
        ]
        + [
            InsightSource(record_text(document, ("filename", "file_type", "status")), 0.7)
            for document in documents
        ]
        + [
            InsightSource(record_text(memory, ("key", "value", "source")), 0.6)
            for memory in memories
        ]
    ).lower()

    completion_hits = count_any(corpus, COMPLETION_WORDS)
    focus_hits = count_any(corpus, FOCUS_WORDS)
    positive_hits = sum(corpus.count(word) for word in POSITIVE_WORDS)
    negative_hits = sum(corpus.count(word) for word in NEGATIVE_WORDS)

    active_days = {
        day
        for day in (
            WEEKDAY_BY_INDEX[(to_datetime(get_value(entry, "created_at")) or datetime.min).weekday()]
            for entry in list(journal_entries) + list(chat_messages) + list(documents) + list(memories)
            if to_datetime(get_value(entry, "created_at")) is not None
        )
    }

    indexed_docs = sum(1 for document in documents if normalize_text(get_value(document, "status")) == "indexed")
    processing_docs = sum(1 for document in documents if normalize_text(get_value(document, "status")) == "processing")

    score = 28
    score += min(22, completion_hits * 4)
    score += min(16, focus_hits * 3)
    score += min(10, positive_hits)
    score += min(8, len(journal_entries) * 2)
    score += min(10, len(chat_messages) // 4)
    score += min(8, len(memories) // 5)
    score += min(10, indexed_docs * 3)
    score += min(4, processing_docs)
    score += min(8, len(active_days) * 2)
    score -= min(18, negative_hits * 3)

    if label in {"Burnout Risk", "Overwhelmed", "Stressed", "Anxious", "Tired", "Low Energy"}:
        score -= 6
    if label in {"Productive", "Focused", "Motivated", "Confident", "Energetic"}:
        score += 4
    if mood_trend == "Improving":
        score += 4
    elif mood_trend == "Declining":
        score -= 4

    return max(0, min(int(round(score)), 100))


def usage_trend_from_change(weekly_percentage_change: float) -> str:
    if weekly_percentage_change > 0.05:
        return "Improving"
    if weekly_percentage_change < -0.05:
        return "Declining"
    return "Stable"


def productivity_category(score: int) -> str:

    if score < 35:
        return "Low"
    if score < 60:
        return "Moderate"
    if score < 85:
        return "High"
    return "Excellent"


def build_recommendations(
    *,

    journal_label: str,
    mood_trend: str,
    productivity_score: int,
    weekly_change: str,
    weekly_usage: WeeklyUsageRead,
) -> list[str]:
    recommendations: list[str] = []

    if productivity_score >= 80:
        recommendations.append("Keep protecting your strongest focus block and reuse the same routine tomorrow.")
    elif productivity_score >= 60:
        recommendations.append("Keep the current rhythm, and make one small task your first priority each morning.")
    else:
        recommendations.append("Take a short break after long focus sessions so your energy stays steadier.")

    if weekly_change.startswith("-"):
        recommendations.append("Schedule important work before noon when your energy is usually easier to sustain.")
    else:
        recommendations.append("Continue your journaling streak so the patterns stay easy to spot week to week.")

    if journal_label in {"Overwhelmed", "Stressed", "Anxious", "Burnout Risk", "Tired", "Low Energy"}:
        recommendations.append("Trim tomorrow to one practical priority and let the rest wait.")
    elif journal_label in {"Creative", "Focused", "Productive", "Motivated"}:
        recommendations.append("Capture the best idea or next step while the momentum is still fresh.")
    elif mood_trend == "Improving":
        recommendations.append("Repeat the habit pattern that seems to be lifting your mood lately.")
    elif mood_trend == "Declining":
        recommendations.append("Add one recovery block or a short walk to help reset your pace.")
    else:
        recommendations.append("Review the day you were busiest and copy one thing that worked well.")

    unique = list(dict.fromkeys(item for item in recommendations if normalize_text(item)))
    return unique[:3]
