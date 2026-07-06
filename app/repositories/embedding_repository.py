from __future__ import annotations

import hashlib
import uuid
from typing import Protocol, Sequence

from sqlalchemy.orm import Session

from app.ai.embeddings.exceptions import EmbeddingRepositoryError
from app.models.embedding import EmbeddingRecord
from app.schemas.embedding import EmbeddingMetadataCreate


def _hash_text(text: str) -> str:
    return hashlib.sha256(text.encode("utf-8")).hexdigest()


class EmbeddingRepository(Protocol):
    def save(self, payload: EmbeddingMetadataCreate) -> EmbeddingRecord:
        ...

    def save_batch(self, payloads: Sequence[EmbeddingMetadataCreate]) -> list[EmbeddingRecord]:
        ...

    def get_by_id(self, embedding_id: str) -> EmbeddingRecord | None:
        ...

    def list_by_source(
        self,
        source_type: str | None = None,
        source_id: str | None = None,
        limit: int | None = None,
    ) -> list[EmbeddingRecord]:
        ...

    def find_by_hash(self, content_hash: str) -> list[EmbeddingRecord]:
        ...


class SQLAlchemyEmbeddingRepository(EmbeddingRepository):
    def __init__(self, db: Session):
        self.db = db

    def save(self, payload: EmbeddingMetadataCreate) -> EmbeddingRecord:
        record = EmbeddingRecord(
            id=payload.id or str(uuid.uuid4()),
            source_type=payload.source_type,
            source_id=payload.source_id,
            content_hash=payload.content_hash,
            provider=payload.provider,
            model_name=payload.model_name,
        )
        try:
            self.db.add(record)
            self.db.commit()
            self.db.refresh(record)
            return record
        except Exception as exc:  # pragma: no cover - defensive rollback path
            self.db.rollback()
            raise EmbeddingRepositoryError("Failed to save embedding metadata") from exc

    def save_batch(self, payloads: Sequence[EmbeddingMetadataCreate]) -> list[EmbeddingRecord]:
        records = [
            EmbeddingRecord(
                id=payload.id or str(uuid.uuid4()),
                source_type=payload.source_type,
                source_id=payload.source_id,
                content_hash=payload.content_hash,
                provider=payload.provider,
                model_name=payload.model_name,
            )
            for payload in payloads
        ]
        try:
            self.db.add_all(records)
            self.db.commit()
            for record in records:
                self.db.refresh(record)
            return records
        except Exception as exc:  # pragma: no cover - defensive rollback path
            self.db.rollback()
            raise EmbeddingRepositoryError("Failed to save embedding metadata batch") from exc

    def get_by_id(self, embedding_id: str) -> EmbeddingRecord | None:
        return self.db.query(EmbeddingRecord).filter(EmbeddingRecord.id == embedding_id).first()

    def list_by_source(
        self,
        source_type: str | None = None,
        source_id: str | None = None,
        limit: int | None = None,
    ) -> list[EmbeddingRecord]:
        query = self.db.query(EmbeddingRecord)
        if source_type is not None:
            query = query.filter(EmbeddingRecord.source_type == source_type)
        if source_id is not None:
            query = query.filter(EmbeddingRecord.source_id == source_id)
        query = query.order_by(EmbeddingRecord.created_at.desc())
        if limit is not None:
            query = query.limit(limit)
        return query.all()

    def find_by_hash(self, content_hash: str) -> list[EmbeddingRecord]:
        return (
            self.db.query(EmbeddingRecord)
            .filter(EmbeddingRecord.content_hash == content_hash)
            .order_by(EmbeddingRecord.created_at.desc())
            .all()
        )


def build_embedding_repository(db: Session) -> SQLAlchemyEmbeddingRepository:
    return SQLAlchemyEmbeddingRepository(db=db)
