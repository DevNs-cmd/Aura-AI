from __future__ import annotations

from typing import Protocol
from uuid import UUID

from sqlalchemy.orm import Session

from app.ai.embeddings.provider import _ensure_text
from app.ai.journal.exceptions import JournalConfigurationError, JournalNotFoundError, JournalRepositoryError
from app.ai.journal.schemas import JournalArtifactUpdate, JournalEntryCreate, JournalEntryUpdate
from app.models.journal import JournalEntry


class JournalRepository(Protocol):
    def create(self, *, user_id: UUID, payload: JournalEntryCreate) -> JournalEntry:
        ...

    def update(self, entry_id: UUID, payload: JournalEntryUpdate) -> JournalEntry:
        ...

    def delete(self, entry_id: UUID) -> JournalEntry:
        ...

    def get_by_id(self, entry_id: UUID) -> JournalEntry | None:
        ...

    def list_by_user(self, user_id: UUID, *, limit: int | None = None) -> list[JournalEntry]:
        ...

    def update_artifacts(self, entry_id: UUID, payload: JournalArtifactUpdate) -> JournalEntry:
        ...


class SQLAlchemyJournalRepository(JournalRepository):
    def __init__(self, db: Session):
        self.db = db

    def _get_active(self, entry_id: UUID) -> JournalEntry | None:
        return (
            self.db.query(JournalEntry)
            .filter(JournalEntry.id == entry_id, JournalEntry.deleted_at.is_(None))
            .first()
        )

    def create(self, *, user_id: UUID, payload: JournalEntryCreate) -> JournalEntry:
        record = JournalEntry(
            user_id=user_id,
            title=_ensure_text(payload.title),
            content=_ensure_text(payload.content),
            summary=None,
            mood=None,
            keywords=[],
            reflection=None,
            follow_up_suggestions=[],
            artifacts={},
        )
        try:
            self.db.add(record)
            self.db.flush()
            self.db.refresh(record)
            return record
        except Exception as exc:  # pragma: no cover - defensive rollback path
            self.db.rollback()
            raise JournalRepositoryError("Failed to create journal entry") from exc

    def update(self, entry_id: UUID, payload: JournalEntryUpdate) -> JournalEntry:
        record = self._get_active(entry_id)
        if record is None:
            raise JournalNotFoundError(f"Journal entry {entry_id} was not found")

        if payload.title is not None:
            record.title = _ensure_text(payload.title)
        if payload.content is not None:
            record.content = _ensure_text(payload.content)

        try:
            self.db.flush()
            self.db.refresh(record)
            return record
        except Exception as exc:  # pragma: no cover - defensive rollback path
            self.db.rollback()
            raise JournalRepositoryError("Failed to update journal entry") from exc

    def delete(self, entry_id: UUID) -> JournalEntry:
        record = self._get_active(entry_id)
        if record is None:
            raise JournalNotFoundError(f"Journal entry {entry_id} was not found")

        try:
            from datetime import datetime

            record.deleted_at = datetime.utcnow()
            self.db.flush()
            self.db.refresh(record)
            return record
        except Exception as exc:  # pragma: no cover - defensive rollback path
            self.db.rollback()
            raise JournalRepositoryError("Failed to delete journal entry") from exc

    def get_by_id(self, entry_id: UUID) -> JournalEntry | None:
        return self._get_active(entry_id)

    def list_by_user(self, user_id: UUID, *, limit: int | None = None) -> list[JournalEntry]:
        query = (
            self.db.query(JournalEntry)
            .filter(JournalEntry.user_id == user_id, JournalEntry.deleted_at.is_(None))
            .order_by(JournalEntry.updated_at.desc(), JournalEntry.created_at.desc())
        )
        if limit is not None:
            query = query.limit(limit)
        return list(query.all())

    def update_artifacts(self, entry_id: UUID, payload: JournalArtifactUpdate) -> JournalEntry:
        record = self._get_active(entry_id)
        if record is None:
            raise JournalNotFoundError(f"Journal entry {entry_id} was not found")

        record.summary = payload.summary
        record.mood = payload.mood
        record.keywords = list(payload.keywords)
        record.reflection = payload.reflection
        record.follow_up_suggestions = list(payload.follow_up_suggestions)
        record.artifacts = payload.model_dump(mode="json", exclude_none=True)

        try:
            self.db.flush()
            self.db.refresh(record)
            return record
        except Exception as exc:  # pragma: no cover - defensive rollback path
            self.db.rollback()
            raise JournalRepositoryError("Failed to update journal artifacts") from exc


def build_journal_repository(db: Session) -> SQLAlchemyJournalRepository:
    if db is None:
        raise JournalConfigurationError("A database session is required to build the journal repository")
    return SQLAlchemyJournalRepository(db=db)
