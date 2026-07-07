from __future__ import annotations

from app.ai.journal.schemas import JournalInsightRead
from app.ai.journal.utils import extract_keywords, infer_mood, normalize_journal_text, summarize_entry


class JournalInsightExtractor:
    def extract(self, *, title: str, content: str) -> JournalInsightRead:
        normalized_title = normalize_journal_text(title)
        normalized_content = normalize_journal_text(content)
        return JournalInsightRead(
            keywords=extract_keywords(normalized_title, normalized_content),
            mood=infer_mood(normalized_title, normalized_content),
            summary=summarize_entry(normalized_title, normalized_content),
        )


def build_journal_insight_extractor() -> JournalInsightExtractor:
    return JournalInsightExtractor()
