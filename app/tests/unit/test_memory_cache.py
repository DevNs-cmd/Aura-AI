from __future__ import annotations

from app.ai.memory.cache import RedisMemoryCache


class FakeRedisClient:
    def __init__(self):
        self.data = {}

    def get(self, key):
        return self.data.get(key)

    def set(self, key, value, ex=None):
        self.data[key] = value
        self.data[f"{key}:ttl"] = ex
        return True

    def delete(self, *keys):
        for key in keys:
            self.data.pop(key, None)
            self.data.pop(f"{key}:ttl", None)
        return len(keys)

    def incr(self, key):
        value = int(self.data.get(key, 0)) + 1
        self.data[key] = str(value)
        return value


def test_redis_memory_cache_reads_writes_and_increments():
    client = FakeRedisClient()
    cache = RedisMemoryCache(client=client, ttl_seconds=120)

    cache.set("memory:item:1", "value")

    assert cache.get("memory:item:1") == "value"
    assert client.data["memory:item:1:ttl"] == 120
    assert cache.increment("memory:user:1:version") == 1
    assert cache.increment("memory:user:1:version") == 2

    cache.delete("memory:item:1")
    assert cache.get("memory:item:1") is None
