from __future__ import annotations

import json
from typing import Protocol

from app.ai.journal.exceptions import JournalCacheError, JournalConfigurationError
from app.ai.journal.schemas import JournalEntryRead
from app.core.config import settings


class JournalCache(Protocol):
    def get(self, key: str) -> str | None:
        ...

    def set(self, key: str, value: str, *, ttl_seconds: int | None = None) -> None:
        ...

    def delete(self, *keys: str) -> None:
        ...

    def increment(self, key: str) -> int:
        ...


class NullJournalCache(JournalCache):
    def get(self, key: str) -> str | None:
        return None

    def set(self, key: str, value: str, *, ttl_seconds: int | None = None) -> None:
        return None

    def delete(self, *keys: str) -> None:
        return None

    def increment(self, key: str) -> int:
        return 0


class RedisJournalCache(JournalCache):
    def __init__(self, *, client=None, url: str | None = None, ttl_seconds: int = 300):
        if client is not None:
            self._client = client
        else:
            try:
                import redis
            except ImportError as exc:  # pragma: no cover - optional dependency guard
                raise JournalConfigurationError("redis is required for the journal cache adapter") from exc

            self._client = redis.Redis.from_url(url or settings.REDIS_URL, decode_responses=True)
            try:
                self._client.ping()
            except Exception as exc:  # pragma: no cover - defensive adapter boundary
                raise JournalConfigurationError("Failed to connect to Redis for the journal cache adapter") from exc

        self._ttl_seconds = ttl_seconds

    def get(self, key: str) -> str | None:
        try:
            return self._client.get(key)
        except Exception:
            return None

    def set(self, key: str, value: str, *, ttl_seconds: int | None = None) -> None:
        try:
            self._client.set(key, value, ex=ttl_seconds if ttl_seconds is not None else self._ttl_seconds)
        except Exception:
            return None

    def delete(self, *keys: str) -> None:
        if not keys:
            return

        try:
            self._client.delete(*keys)
        except Exception:
            return None

    def increment(self, key: str) -> int:
        try:
            return int(self._client.incr(key))
        except Exception:
            return 0


def build_journal_cache(*, client=None, url: str | None = None, ttl_seconds: int = 300) -> JournalCache:
    try:
        return RedisJournalCache(client=client, url=url, ttl_seconds=ttl_seconds)
    except JournalConfigurationError:
        return NullJournalCache()


def dumps_journal_entries(items: list[JournalEntryRead]) -> str:
    return json.dumps([item.model_dump(mode="json") for item in items])


def loads_journal_entries(payload: str) -> list[JournalEntryRead]:
    data = json.loads(payload)
    if not isinstance(data, list):
        raise JournalCacheError("Cached journal payload must be a list")
    return [JournalEntryRead.model_validate(item) for item in data]
