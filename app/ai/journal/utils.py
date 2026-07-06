from __future__ import annotations

import re
from collections import Counter

from app.ai.embeddings.provider import _ensure_text

TOKEN_RE = re.compile(r"[A-Za-z0-9_']+")
SENTENCE_RE = re.compile(r"(?<=[.!?])\s+")

STOPWORDS = {
    "a",
    "about",
    "after",
    "again",
    "all",
    "also",
    "an",
    "and",
    "any",
    "are",
    "as",
    "at",
    "be",
    "because",
    "been",
    "before",
    "being",
    "but",
    "by",
    "can",
    "could",
    "did",
    "do",
    "does",
    "doing",
    "down",
    "during",
    "each",
    "for",
    "from",
    "had",
    "has",
    "have",
    "having",
    "he",
    "her",
    "here",
    "hers",
    "him",
    "his",
    "how",
    "i",
    "if",
    "in",
    "into",
    "is",
    "it",
    "its",
    "just",
    "me",
    "more",
    "most",
    "my",
    "no",
    "not",
    "of",
    "off",
    "on",
    "once",
    "one",
    "only",
    "or",
    "other",
    "our",
    "out",
    "over",
    "re",
    "s",
    "same",
    "she",
    "should",
    "so",
    "some",
    "such",
    "t",
    "than",
    "that",
    "the",
    "their",
    "them",
    "then",
    "there",
    "these",
    "they",
    "this",
    "those",
    "through",
    "to",
    "too",
    "under",
    "until",
    "up",
    "very",
    "was",
    "we",
    "were",
    "what",
    "when",
    "where",
    "which",
    "while",
    "who",
    "will",
    "with",
    "would",
    "you",
    "your",
}

MOOD_LEXICON: dict[str, set[str]] = {
    "joyful": {"joy", "happy", "glad", "excited", "delighted", "proud", "cheerful", "grateful"},
    "calm": {"calm", "peaceful", "steady", "content", "relaxed", "grounded", "centered"},
    "hopeful": {"hopeful", "optimistic", "encouraged", "motivated", "inspired", "determined"},
    "reflective": {"reflect", "thoughtful", "remembering", "learning", "processing", "considering"},
    "anxious": {"anxious", "worried", "nervous", "uneasy", "stressed", "tense", "uncertain"},
    "sad": {"sad", "down", "lonely", "hurt", "grief", "heavy", "tired"},
    "frustrated": {"frustrated", "angry", "annoyed", "irritated", "stuck", "overwhelmed"},
}


def normalize_journal_text(text: str) -> str:
    return _ensure_text(text)


def split_sentences(text: str) -> list[str]:
    normalized = normalize_journal_text(text)
    if not normalized:
        return []

    sentences = [part.strip() for part in SENTENCE_RE.split(normalized) if part.strip()]
    return sentences if sentences else [normalized]


def tokenize(text: str) -> list[str]:
    normalized = normalize_journal_text(text).lower()
    return TOKEN_RE.findall(normalized)


def extract_keywords(title: str, content: str, *, limit: int = 5) -> list[str]:
    tokens = tokenize(f"{title} {content}")
    if not tokens:
        return []

    counts: Counter[str] = Counter()
    first_positions: dict[str, int] = {}
    title_tokens = set(tokenize(title))

    for position, token in enumerate(tokens):
        if len(token) < 3 or token in STOPWORDS:
            continue
        counts[token] += 2 if token in title_tokens else 1
        first_positions.setdefault(token, position)

    ranked = sorted(counts, key=lambda token: (-counts[token], first_positions[token], token))
    return ranked[:limit]


def infer_mood(title: str, content: str) -> str:
    tokens = set(tokenize(f"{title} {content}"))
    if not tokens:
        return "neutral"

    scores = {
        mood: sum(1 for keyword in keywords if keyword in tokens)
        for mood, keywords in MOOD_LEXICON.items()
    }
    best_mood, best_score = max(scores.items(), key=lambda item: (item[1], item[0]))
    return best_mood if best_score > 0 else "neutral"


def summarize_entry(title: str, content: str, *, max_length: int = 280) -> str:
    normalized_title = normalize_journal_text(title)
    normalized_content = normalize_journal_text(content)
    sentences = split_sentences(normalized_content)
    core = " ".join(sentences[:2]).strip()

    if normalized_title and core:
        summary = f"{normalized_title}: {core}"
    else:
        summary = normalized_title or core or normalized_content

    if len(summary) > max_length:
        summary = summary[: max_length - 3].rstrip() + "..."
    return summary


def build_entry_text(title: str, content: str) -> str:
    normalized_title = normalize_journal_text(title)
    normalized_content = normalize_journal_text(content)
    if normalized_title and normalized_content:
        return f"{normalized_title}\n\n{normalized_content}"
    return normalized_title or normalized_content
