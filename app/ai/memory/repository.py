from __future__ import annotations

from typing import Protocol
from uuid import UUID

from sqlalchemy.orm import Session

from app.ai.embeddings.provider import _ensure_text
from app.ai.memory.exceptions import MemoryConfigurationError, MemoryNotFoundError, MemoryRepositoryError
from app.ai.memory.schemas import MemoryCreate, MemoryUpdate
from app.models.memory import Memory


class MemoryRepository(Protocol):
    def create(self, payload: MemoryCreate) -> Memory:
        ...

    def update(self, memory_id: UUID, payload: MemoryUpdate) -> Memory:
        ...

    def delete(self, memory_id: UUID) -> None:
        ...

    def get_by_id(self, memory_id: UUID) -> Memory | None:
        ...

    def list_by_user(self, user_id: UUID, *, limit: int | None = None) -> list[Memory]:
        ...


class SQLAlchemyMemoryRepository(MemoryRepository):
    def __init__(self, db: Session):
        self.db = db

    def create(self, payload: MemoryCreate) -> Memory:
        record = Memory(
            user_id=payload.user_id,
            key=_ensure_text(payload.key),
            value=_ensure_text(payload.value),
            source=_ensure_text(payload.source),
        )

        try:
            self.db.add(record)
            self.db.commit()
            self.db.refresh(record)
            return record
        except Exception as exc:  # pragma: no cover - defensive rollback path
            self.db.rollback()
            raise MemoryRepositoryError("Failed to create memory record") from exc

    def update(self, memory_id: UUID, payload: MemoryUpdate) -> Memory:
        record = self.get_by_id(memory_id)
        if record is None:
            raise MemoryNotFoundError(f"Memory {memory_id} was not found")

        if payload.key is not None:
            record.key = _ensure_text(payload.key)
        if payload.value is not None:
            record.value = _ensure_text(payload.value)
        if payload.source is not None:
            record.source = _ensure_text(payload.source)

        try:
            self.db.commit()
            self.db.refresh(record)
            return record
        except Exception as exc:  # pragma: no cover - defensive rollback path
            self.db.rollback()
            raise MemoryRepositoryError("Failed to update memory record") from exc

    def delete(self, memory_id: UUID) -> None:
        record = self.get_by_id(memory_id)
        if record is None:
            raise MemoryNotFoundError(f"Memory {memory_id} was not found")

        try:
            self.db.delete(record)
            self.db.commit()
        except Exception as exc:  # pragma: no cover - defensive rollback path
            self.db.rollback()
            raise MemoryRepositoryError("Failed to delete memory record") from exc

    def get_by_id(self, memory_id: UUID) -> Memory | None:
        return self.db.query(Memory).filter(Memory.id == memory_id).first()

    def list_by_user(self, user_id: UUID, *, limit: int | None = None) -> list[Memory]:
        query = self.db.query(Memory).filter(Memory.user_id == user_id).order_by(
            Memory.updated_at.desc(),
            Memory.created_at.desc(),
        )
        if limit is not None:
            query = query.limit(limit)
        return list(query.all())


def build_memory_repository(db: Session) -> SQLAlchemyMemoryRepository:
    if db is None:
        raise MemoryConfigurationError("A database session is required to build the memory repository")
    return SQLAlchemyMemoryRepository(db=db)
