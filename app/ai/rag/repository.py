from __future__ import annotations

from typing import Protocol
from uuid import UUID

from sqlalchemy.orm import Session

from app.ai.rag.exceptions import RagConfigurationError, RagRepositoryError
from app.models.document import Document


class DocumentRepository(Protocol):
    def get_by_id(self, document_id: UUID) -> Document | None:
        ...

    def get_by_ids(self, document_ids: list[UUID]) -> list[Document]:
        ...


class SQLAlchemyDocumentRepository(DocumentRepository):
    def __init__(self, db: Session):
        self.db = db

    def get_by_id(self, document_id: UUID) -> Document | None:
        try:
            return self.db.query(Document).filter(Document.id == document_id).first()
        except Exception as exc:  # pragma: no cover - defensive adapter boundary
            raise RagRepositoryError("Failed to load document metadata") from exc

    def get_by_ids(self, document_ids: list[UUID]) -> list[Document]:
        if not document_ids:
            return []
        try:
            return list(self.db.query(Document).filter(Document.id.in_(document_ids)).all())
        except Exception as exc:  # pragma: no cover - defensive adapter boundary
            raise RagRepositoryError("Failed to load document metadata batch") from exc


def build_document_repository(db: Session) -> SQLAlchemyDocumentRepository:
    if db is None:
        raise RagConfigurationError("A database session is required to build the document repository")
    return SQLAlchemyDocumentRepository(db=db)
