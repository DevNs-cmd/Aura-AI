from __future__ import annotations

from app.ai.journal.schemas import JournalInsightRead, JournalReflectionRead
from app.ai.journal.utils import normalize_journal_text


class JournalReflectionGenerator:
    def generate(self, *, title: str, content: str, insights: JournalInsightRead) -> JournalReflectionRead:
        normalized_title = normalize_journal_text(title)
        normalized_content = normalize_journal_text(content)
        focus = insights.keywords[0] if insights.keywords else (normalized_title or normalized_content).split(" ")[0]

        reflection = (
            f"This entry carries a {insights.mood} tone and centers on {focus}. "
            f"Your summary suggests: {insights.summary}"
        )
        suggestions = [
            f"Write one small next step connected to {focus}.",
            f"Notice what in this entry made you feel {insights.mood}.",
            f"Capture one thing you want to remember about {focus} tomorrow.",
        ]
        return JournalReflectionRead(reflection=reflection, follow_up_suggestions=suggestions)


def build_journal_reflection_generator() -> JournalReflectionGenerator:
    return JournalReflectionGenerator()
