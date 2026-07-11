from __future__ import annotations

from typing import Any

from app.ai.context.schemas import AIContext
from app.ai.journal.schemas import JournalEntryCreate
from app.ai.llm.schemas import LLMResponse
from app.ai.memory.schemas import MemoryCreate
from app.utils.pdf_generator import PDFReportData, build_pdf_report

from .schemas import ChatRequest


def normalize_text(value: Any) -> str | None:
    if value is None:
        return None
    text = str(value).strip()
    return text or None


def build_default_memory_payloads(request: ChatRequest, response: LLMResponse) -> list[MemoryCreate]:
    return [
        MemoryCreate(
            user_id=request.user_id,
            key="chat:last_assistant_reply",
            value=response.content,
            source="chat",
        )
    ]


def build_default_journal_payload(request: ChatRequest, response: LLMResponse) -> JournalEntryCreate:
    title = normalize_text(request.query) or "Chat response"
    title = title[:255]
    return JournalEntryCreate(title=title, content=response.content)


def infer_pdf_report_type(query: str) -> str | None:
    normalized_query = (normalize_text(query) or "").lower()
    if not normalized_query:
        return None

    if not any(keyword in normalized_query for keyword in ("export", "download", "generate", "save", "pdf", "report")):
        return None

    if any(keyword in normalized_query for keyword in ("conversation", "chat transcript", "export chat", "export this conversation", "download chat", "chat pdf")):
        return "chat"
    if any(keyword in normalized_query for keyword in ("journal", "my journal", "export journal", "download journal")):
        return "journal"
    if any(keyword in normalized_query for keyword in ("weekly", "week", "weekly report", "weekly insights")):
        return "weekly"
    if any(keyword in normalized_query for keyword in ("productivity", "productivity report")):
        return "productivity"
    if any(keyword in normalized_query for keyword in ("monthly", "month", "monthly report")):
        return "monthly"
    if any(keyword in normalized_query for keyword in ("report pdf", "generate report", "export report", "download report", "ai insights", "insights report")):
        return "weekly"
    return None


def build_default_pdf_payload(request: ChatRequest, context: AIContext, response: LLMResponse) -> dict[str, Any] | None:
    report_type = infer_pdf_report_type(request.query)
    if report_type is None:
        return None

    summary = normalize_text(context.conversation.summary)
    if summary is None and report_type in {"chat", "weekly", "monthly", "productivity"}:
        summary = normalize_text(response.content)

    payload: dict[str, Any] = {
        "report_type": report_type,
        "title": _build_pdf_title(request, report_type),
        "user": str(request.user_id),
        "date": context.created_at,
        "chat_summary": summary,
        "conversation": list(context.conversation.messages),
        "journal_entries": list(context.journal.entries),
        "ai_insights": list(context.journal.insights),
        "mood": _extract_keyword_value(context.memory.memories, ("mood", "emotion", "feeling")),
        "productivity": _extract_keyword_value(context.memory.memories, ("productivity", "focus", "energy")),
        "goals": _extract_keyword_values(context.memory.memories, ("goal", "goals")),
        "tasks": _extract_keyword_values(context.memory.memories, ("task", "tasks", "todo", "to-do")),
        "recommendations": _extract_recommendations(response),
        "metadata": {
            "query": request.query,
            "conversation_id": str(request.conversation_id) if request.conversation_id is not None else None,
            "session_id": str(request.session_id) if request.session_id is not None else None,
        },
    }
    payload["metadata"] = {key: value for key, value in payload["metadata"].items() if normalize_text(value) is not None}
    if payload["report_type"] == "chat":
        payload["conversation"] = [
            *payload["conversation"],
            {"role": "assistant", "content": response.content},
        ]
    if payload["report_type"] in {"weekly", "monthly", "productivity"} and not payload["recommendations"]:
        payload["recommendations"] = [response.content]
    return payload


def build_pdf_report_bytes(payload: dict[str, Any]) -> bytes:
    return build_pdf_report(PDFReportData.model_validate(payload))


def _build_pdf_title(request: ChatRequest, report_type: str) -> str:
    query = normalize_text(request.query)
    if query:
        if report_type == "chat":
            return "Conversation Export"
        if report_type == "journal":
            return "Journal Export"
        if report_type == "weekly":
            return "Weekly Insights Report"
        if report_type == "productivity":
            return "Productivity Report"
        if report_type == "monthly":
            return "Monthly Report"
    return "Aura AI Report"


def _extract_keyword_values(items: list[dict[str, Any]], keywords: tuple[str, ...]) -> list[str]:
    values: list[str] = []
    for item in items:
        if not isinstance(item, dict):
            continue
        for key in keywords:
            raw = item.get(key)
            text = normalize_text(raw)
            if text is not None:
                values.append(text)
                break
    return values


def _extract_keyword_value(items: list[dict[str, Any]], keywords: tuple[str, ...]) -> str | None:
    values = _extract_keyword_values(items, keywords)
    return values[0] if values else None


def _extract_recommendations(response: LLMResponse) -> list[str]:
    content = normalize_text(response.content)
    if content is None:
        return []
    lines = [line.strip(" -*\t") for line in content.splitlines()]
    recommendations = [line for line in lines if line]
    return recommendations[:8]
