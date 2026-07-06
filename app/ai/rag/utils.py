from __future__ import annotations

from typing import Any
from uuid import UUID

from app.ai.embeddings.provider import _ensure_text
from app.ai.rag.exceptions import RagValidationError
from app.ai.rag.schemas import RagDocumentMetadata


def normalize_query(text: str) -> str:
    try:
        return _ensure_text(text)
    except Exception as exc:
        raise RagValidationError(str(exc)) from exc


def extract_document_id(metadata: dict[str, Any]) -> UUID | None:
    raw = metadata.get("document_id") or metadata.get("source_id")
    if raw is None:
        return None
    try:
        return UUID(str(raw))
    except (TypeError, ValueError):
        return None


def extract_chunk_id(metadata: dict[str, Any], embedding_id: str) -> str:
    raw = metadata.get("chunk_id") or metadata.get("chunk") or metadata.get("id") or embedding_id
    return str(raw)


def extract_chunk_text(metadata: dict[str, Any]) -> str | None:
    raw = metadata.get("chunk_text") or metadata.get("text") or metadata.get("content")
    if raw is None:
        return None
    text = str(raw).strip()
    return text or None


def build_document_metadata(document: RagDocumentMetadata | Any | None) -> dict[str, Any]:
    if document is None:
        return {}
    if isinstance(document, RagDocumentMetadata):
        return document.model_dump(mode="json")

    data = {
        "id": getattr(document, "id", None),
        "user_id": getattr(document, "user_id", None),
        "filename": getattr(document, "filename", None),
        "file_path": getattr(document, "file_path", None),
        "file_type": getattr(document, "file_type", None),
        "size_bytes": getattr(document, "size_bytes", None),
        "status": getattr(document, "status", None),
        "created_at": getattr(document, "created_at", None),
    }
    return {key: value for key, value in data.items() if value is not None}


def build_chunk_metadata(metadata: dict[str, Any], *, embedding_id: str, chunk_id: str) -> dict[str, Any]:
    cleaned = dict(metadata)
    cleaned.pop("chunk_text", None)
    cleaned["embedding_id"] = embedding_id
    cleaned["chunk_id"] = chunk_id
    return cleaned


def merge_metadata(
    *,
    document: RagDocumentMetadata | Any | None,
    chunk_metadata: dict[str, Any],
) -> dict[str, Any]:
    return {
        "document": build_document_metadata(document),
        "chunk": dict(chunk_metadata),
    }
