from __future__ import annotations

from typing import Protocol
from uuid import UUID

from sqlalchemy.orm import Session

from app.ai.insights.exceptions import InsightsConfigurationError, InsightsRepositoryError
from app.models.chat import ChatSession, Message
from app.models.document import Document
from app.models.journal import JournalEntry
from app.models.memory import Memory


class InsightsRepository(Protocol):
    def list_journal_entries(self, user_id: UUID | str, *, limit: int | None = None) -> list[JournalEntry]:
        ...

    def list_chat_messages(self, user_id: UUID | str, *, limit: int | None = None) -> list[Message]:
        ...

    def list_documents(self, user_id: UUID | str, *, limit: int | None = None) -> list[Document]:
        ...

    def list_memories(self, user_id: UUID | str, *, limit: int | None = None) -> list[Memory]:
        ...


class SQLAlchemyInsightsRepository(InsightsRepository):
    def __init__(self, db: Session):
        self.db = db

    def list_journal_entries(self, user_id: UUID | str, *, limit: int | None = None) -> list[JournalEntry]:
        try:
            query = (
                self.db.query(JournalEntry)
                .filter(JournalEntry.user_id == user_id, JournalEntry.deleted_at.is_(None))
                .order_by(JournalEntry.created_at.asc(), JournalEntry.updated_at.asc())
            )
            if limit is not None:
                query = query.limit(limit)
            return list(query.all())
        except Exception as exc:  # pragma: no cover - defensive adapter boundary
            raise InsightsRepositoryError("Failed to load journal entries") from exc

    def list_chat_messages(self, user_id: UUID | str, *, limit: int | None = None) -> list[Message]:
        try:
            query = (
                self.db.query(Message)
                .join(ChatSession, Message.session_id == ChatSession.id)
                .filter(ChatSession.user_id == user_id)
                .order_by(Message.created_at.asc(), Message.id.asc())
            )
            if limit is not None:
                query = query.limit(limit)
            return list(query.all())
        except Exception as exc:  # pragma: no cover - defensive adapter boundary
            raise InsightsRepositoryError("Failed to load chat messages") from exc

    def list_documents(self, user_id: UUID | str, *, limit: int | None = None) -> list[Document]:
        try:
            query = (
                self.db.query(Document)
                .filter(Document.user_id == user_id)
                .order_by(Document.created_at.asc(), Document.id.asc())
            )
            if limit is not None:
                query = query.limit(limit)
            return list(query.all())
        except Exception as exc:  # pragma: no cover - defensive adapter boundary
            raise InsightsRepositoryError("Failed to load documents") from exc

    def list_memories(self, user_id: UUID | str, *, limit: int | None = None) -> list[Memory]:
        try:
            query = (
                self.db.query(Memory)
                .filter(Memory.user_id == user_id)
                .order_by(Memory.created_at.asc(), Memory.updated_at.asc())
            )
            if limit is not None:
                query = query.limit(limit)
            return list(query.all())
        except Exception as exc:  # pragma: no cover - defensive adapter boundary
            raise InsightsRepositoryError("Failed to load memories") from exc


def build_insights_repository(db: Session) -> SQLAlchemyInsightsRepository:
    if db is None:
        raise InsightsConfigurationError("A database session is required to build the insights repository")
    return SQLAlchemyInsightsRepository(db=db)
