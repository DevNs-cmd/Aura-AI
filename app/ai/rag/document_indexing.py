from __future__ import annotations

import os
from dataclasses import dataclass
from typing import Iterable
from uuid import UUID

from app.ai.embeddings.service import EmbeddingService, build_embedding_service
from app.ai.vectorstore import VectorStore, build_vector_store

# Note: Chroma adapter expects numeric embeddings plus metadata fields.
# RAG retrieval helpers require at least: document_id, chunk_text, chunk_id.


@dataclass(frozen=True)

class ChunkSpec:
    chunk_size_chars: int = 1500
    chunk_overlap_chars: int = 200


def _read_text_file(path: str) -> str:
    with open(path, "rb") as f:
        raw = f.read()
    # Best-effort decode.
    for encoding in ("utf-8", "utf-16", "latin-1"):
        try:
            return raw.decode(encoding, errors="ignore")
        except Exception:
            continue
    return raw.decode("latin-1", errors="ignore")


def _extract_pdf_text(path: str) -> str:
    """Extract text from a PDF using pypdf."""
    try:
        from pypdf import PdfReader  # type: ignore[import]
        reader = PdfReader(path)
        pages: list[str] = []
        for page in reader.pages:
            text = page.extract_text() or ""
            if text.strip():
                pages.append(text)
        return "\n\n".join(pages)
    except ImportError:
        # pypdf not installed — fall back to raw decode (produces garbage for PDFs)
        return _read_text_file(path)
    except Exception as exc:
        raise ValueError(f"Failed to extract text from PDF: {exc}") from exc


def extract_document_text(file_path: str, file_type: str | None = None) -> str:
    """Extract plain text from a document file.

    Supports:
      - .txt / .md  — direct UTF-8 read
      - .pdf        — pypdf page extraction
      - others      — best-effort byte decode
    """

    if not file_path or not os.path.exists(file_path):
        raise FileNotFoundError(f"Document file not found: {file_path}")

    ext = os.path.splitext(file_path)[1].lower()

    if ext in {".txt", ".md"}:
        return _read_text_file(file_path)

    if ext == ".pdf" or (file_type or "").lower() == "application/pdf":
        return _extract_pdf_text(file_path)

    # Fallback: attempt decode.
    return _read_text_file(file_path)


def chunk_text(text: str, *, spec: ChunkSpec = ChunkSpec()) -> list[str]:
    if not text or not text.strip():
        return []

    size = max(200, int(spec.chunk_size_chars))
    overlap = max(0, int(spec.chunk_overlap_chars))
    overlap = min(overlap, size - 1)

    clean = "\n".join(line.strip() for line in text.splitlines() if line.strip())

    chunks: list[str] = []
    start = 0
    text_len = len(clean)

    while start < text_len:
        end = min(text_len, start + size)
        chunk = clean[start:end].strip()
        if chunk:
            chunks.append(chunk)
        if end >= text_len:
            break
        start = end - overlap
        if start < 0:
            start = 0

    return chunks


def _build_document_chunk_metadata(
    *,
    user_id: UUID,
    document_id: UUID,
    chunk_index: int,
    chunk_text_value: str,
    file_name: str,
) -> dict:
    chunk_id = f"{document_id}_chunk_{chunk_index}"
    return {
        "user_id": str(user_id),
        "document_id": str(document_id),
        "chunk_index": chunk_index,
        "chunk_id": chunk_id,
        "file_name": file_name,
        # Required by Rag retrieval helpers
        "chunk_text": chunk_text_value,
    }


def upsert_document_chunks_to_chroma(
    *,
    user_id: UUID,
    document_id: UUID,
    file_name: str,
    chunks: Iterable[str],
    embedding_service: EmbeddingService | None = None,
    vector_store: VectorStore | None = None,
) -> None:
    embedding_service = embedding_service or build_embedding_service()
    vector_store = vector_store or build_vector_store()

    chunk_list = list(chunks)
    if not chunk_list:
        return

    # Batch embed
    vectors = embedding_service.generate_batch_embeddings(chunk_list)

    items: list[tuple[str, list[float], dict]] = []

    for idx, (chunk_text_value, vector) in enumerate(zip(chunk_list, vectors, strict=True)):
        embedding_id = f"document_{document_id}_chunk_{idx}"

        meta = _build_document_chunk_metadata(
            user_id=user_id,
            document_id=document_id,
            chunk_index=idx,
            chunk_text_value=chunk_text_value,
            file_name=file_name,
        )
        items.append((embedding_id, vector, meta))

    # Adapter expects Sequence[tuple[str, Sequence[float], dict[str, Any]]]
    vector_store.upsert_batch(items)

