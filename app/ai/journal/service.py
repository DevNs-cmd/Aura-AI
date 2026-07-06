from __future__ import annotations

from uuid import UUID

from sqlalchemy.orm import Session

from app.ai.embeddings.provider import _ensure_text
from app.ai.embeddings.service import EmbeddingService, build_embedding_service
from app.ai.journal.cache import JournalCache, build_journal_cache, dumps_journal_entries, loads_journal_entries
from app.ai.journal.exceptions import (
    JournalCacheError,
    JournalConfigurationError,
    JournalNotFoundError,
    JournalValidationError,
)
from app.ai.journal.pipeline import JournalPipeline, build_journal_pipeline
from app.ai.journal.repository import JournalRepository, build_journal_repository
from app.ai.journal.schemas import JournalEntryCreate, JournalEntryRead, JournalEntryUpdate
from app.ai.memory.repository import build_memory_repository
from app.ai.memory.service import MemoryService, build_memory_service
from app.ai.vectorstore import VectorStore, build_vector_store


class JournalService:
    def __init__(
        self,
        *,
        db: Session,
        repository: JournalRepository,
        cache: JournalCache | None = None,
        pipeline: JournalPipeline,
    ):
        self.db = db
        self.repository = repository
        self.cache = cache
        self.pipeline = pipeline

    @staticmethod
    def _version_key(user_id: UUID) -> str:
        return f"journal:user:{user_id}:version"

    @staticmethod
    def _entry_key(entry_id: UUID, version: int) -> str:
        return f"journal:entry:{entry_id}:v{version}"

    @staticmethod
    def _list_key(user_id: UUID, version: int, limit: int | None) -> str:
        return f"journal:user:{user_id}:list:v{version}:limit:{limit if limit is not None else 'all'}"

    def _get_version(self, user_id: UUID) -> int:
        if self.cache is None:
            return 0

        cached = self.cache.get(self._version_key(user_id))
        if cached is None:
            return 0
        try:
            return int(cached)
        except ValueError as exc:  # pragma: no cover - defensive cache boundary
            raise JournalCacheError("Invalid journal cache version") from exc

    def _bump_version(self, user_id: UUID) -> int:
        if self.cache is None:
            return 0
        return self.cache.increment(self._version_key(user_id))

    def _cache_entry(self, entry: JournalEntryRead, *, version: int) -> None:
        if self.cache is None:
            return
        self.cache.set(self._entry_key(entry.id, version), entry.model_dump_json())

    def _cache_entries(self, user_id: UUID, limit: int | None, entries: list[JournalEntryRead]) -> None:
        if self.cache is None:
            return
        version = self._get_version(user_id)
        self.cache.set(self._list_key(user_id, version, limit), dumps_journal_entries(entries))

    def _get_cached_entry(self, entry_id: UUID, user_id: UUID) -> JournalEntryRead | None:
        if self.cache is None:
            return None
        version = self._get_version(user_id)
        cached = self.cache.get(self._entry_key(entry_id, version))
        if cached is None:
            return None
        return JournalEntryRead.model_validate_json(cached)

    def _get_cached_entries(self, user_id: UUID, limit: int | None) -> list[JournalEntryRead] | None:
        if self.cache is None:
            return None
        version = self._get_version(user_id)
        cached = self.cache.get(self._list_key(user_id, version, limit))
        if cached is None:
            return None
        return loads_journal_entries(cached)

    @staticmethod
    def _read_entry(entry) -> JournalEntryRead:
        return JournalEntryRead.model_validate(entry, from_attributes=True)

    def _ensure_owner(self, entry_id: UUID, user_id: UUID) -> JournalEntryRead:
        cached = self._get_cached_entry(entry_id, user_id)
        if cached is not None:
            return cached

        record = self.repository.get_by_id(entry_id)
        if record is None or str(record.user_id) != str(user_id):
            raise JournalNotFoundError(f"Journal entry {entry_id} was not found")
        return self._read_entry(record)

    @staticmethod
    def _normalize_create_payload(payload: JournalEntryCreate) -> JournalEntryCreate:
        return JournalEntryCreate(title=_ensure_text(payload.title), content=_ensure_text(payload.content))

    @staticmethod
    def _normalize_update_payload(payload: JournalEntryUpdate) -> JournalEntryUpdate:
        if payload.title is None and payload.content is None:
            raise JournalValidationError("At least one field must be provided for update")
        return JournalEntryUpdate(
            title=_ensure_text(payload.title) if payload.title is not None else None,
            content=_ensure_text(payload.content) if payload.content is not None else None,
        )

    def create_entry(self, *, user_id: UUID, payload: JournalEntryCreate) -> JournalEntryRead:
        normalized = self._normalize_create_payload(payload)
        try:
            result = self.pipeline.create_entry(user_id=user_id, payload=normalized)
            self.db.commit()
            version = self._bump_version(user_id)
            self._cache_entry(result.entry, version=version)
            return result.entry
        except Exception:
            self.db.rollback()
            raise

    def update_entry(self, *, user_id: UUID, entry_id: UUID, payload: JournalEntryUpdate) -> JournalEntryRead:
        self._ensure_owner(entry_id, user_id)
        normalized = self._normalize_update_payload(payload)
        try:
            result = self.pipeline.update_entry(user_id=user_id, entry_id=entry_id, payload=normalized)
            self.db.commit()
            version = self._bump_version(user_id)
            self._cache_entry(result.entry, version=version)
            return result.entry
        except Exception:
            self.db.rollback()
            raise

    def get_entry(self, *, user_id: UUID, entry_id: UUID) -> JournalEntryRead:
        cached = self._get_cached_entry(entry_id, user_id)
        if cached is not None:
            return cached

        record = self.repository.get_by_id(entry_id)
        if record is None or str(record.user_id) != str(user_id):
            raise JournalNotFoundError(f"Journal entry {entry_id} was not found")

        entry = self._read_entry(record)
        self._cache_entry(entry, version=self._get_version(user_id))
        return entry

    def list_entries(self, *, user_id: UUID, limit: int | None = None) -> list[JournalEntryRead]:
        if limit is not None and limit <= 0:
            raise JournalValidationError("limit must be positive")

        cached = self._get_cached_entries(user_id, limit)
        if cached is not None:
            return cached

        records = self.repository.list_by_user(user_id, limit=limit)
        entries = [self._read_entry(record) for record in records]
        self._cache_entries(user_id, limit, entries)
        return entries

    def delete_entry(self, *, user_id: UUID, entry_id: UUID) -> JournalEntryRead:
        self._ensure_owner(entry_id, user_id)
        try:
            record = self.repository.delete(entry_id)
            self.db.commit()
            deleted = self._read_entry(record)
            self._bump_version(user_id)
            return deleted
        except Exception:
            self.db.rollback()
            raise


def build_journal_service(
    *,
    db: Session,
    repository: JournalRepository | None = None,
    cache: JournalCache | None = None,
    embedding_service: EmbeddingService | None = None,
    vector_store: VectorStore | None = None,
    memory_service: MemoryService | None = None,
    pipeline: JournalPipeline | None = None,
) -> JournalService:
    repository = repository or build_journal_repository(db)
    cache = cache or build_journal_cache()
    embedding_service = embedding_service or build_embedding_service()
    vector_store = vector_store or build_vector_store()
    memory_service = memory_service or build_memory_service(
        repository=build_memory_repository(db),
    )
    pipeline = pipeline or build_journal_pipeline(
        repository=repository,
        embedding_service=embedding_service,
        vector_store=vector_store,
        memory_service=memory_service,
    )

    return JournalService(
        db=db,
        repository=repository,
        cache=cache,
        pipeline=pipeline,
    )
