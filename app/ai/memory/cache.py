from __future__ import annotations

import json
from typing import Protocol

from app.ai.memory.exceptions import MemoryCacheError, MemoryConfigurationError
from app.ai.memory.schemas import MemoryRead, MemoryRetrievalResult
from app.core.config import settings


class MemoryCache(Protocol):
    def get(self, key: str) -> str | None:
        ...

    def set(self, key: str, value: str, *, ttl_seconds: int | None = None) -> None:
        ...

    def delete(self, *keys: str) -> None:
        ...

    def increment(self, key: str) -> int:
        ...


class RedisMemoryCache(MemoryCache):
    def __init__(self, *, client=None, url: str | None = None, ttl_seconds: int = 300):
        if client is not None:
            self._client = client
        else:
            try:
                import redis
            except ImportError as exc:  # pragma: no cover - optional dependency guard
                raise MemoryConfigurationError("redis is required for the memory cache adapter") from exc

            self._client = redis.Redis.from_url(url or settings.REDIS_URL, decode_responses=True)

        self._ttl_seconds = ttl_seconds

    def get(self, key: str) -> str | None:
        try:
            return self._client.get(key)
        except Exception as exc:  # pragma: no cover - defensive adapter boundary
            raise MemoryCacheError("Failed to read from the memory cache") from exc

    def set(self, key: str, value: str, *, ttl_seconds: int | None = None) -> None:
        try:
            self._client.set(key, value, ex=ttl_seconds if ttl_seconds is not None else self._ttl_seconds)
        except Exception as exc:  # pragma: no cover - defensive adapter boundary
            raise MemoryCacheError("Failed to write to the memory cache") from exc

    def delete(self, *keys: str) -> None:
        if not keys:
            return

        try:
            self._client.delete(*keys)
        except Exception as exc:  # pragma: no cover - defensive adapter boundary
            raise MemoryCacheError("Failed to delete memory cache keys") from exc

    def increment(self, key: str) -> int:
        try:
            return int(self._client.incr(key))
        except Exception as exc:  # pragma: no cover - defensive adapter boundary
            raise MemoryCacheError("Failed to increment memory cache key") from exc


def build_memory_cache(*, client=None, url: str | None = None, ttl_seconds: int = 300) -> RedisMemoryCache:
    return RedisMemoryCache(client=client, url=url, ttl_seconds=ttl_seconds)


def dumps_memory_reads(items: list[MemoryRead]) -> str:
    return json.dumps([item.model_dump(mode="json") for item in items])


def loads_memory_reads(payload: str) -> list[MemoryRead]:
    data = json.loads(payload)
    if not isinstance(data, list):
        raise MemoryCacheError("Cached memory payload must be a list")
    return [MemoryRead.model_validate(item) for item in data]


def dumps_memory_retrieval_results(items: list[MemoryRetrievalResult]) -> str:
    return json.dumps([item.model_dump(mode="json") for item in items])


def loads_memory_retrieval_results(payload: str) -> list[MemoryRetrievalResult]:
    data = json.loads(payload)
    if not isinstance(data, list):
        raise MemoryCacheError("Cached retrieval payload must be a list")
    return [MemoryRetrievalResult.model_validate(item) for item in data]
