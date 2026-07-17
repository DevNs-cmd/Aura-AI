from __future__ import annotations

from datetime import datetime, timezone
UTC = timezone.utc
from types import SimpleNamespace
from uuid import uuid4

from app.ai.memory.schemas import MemoryCreate, MemoryRead, MemoryUpdate
from app.ai.memory.service import MemoryService
from app.ai.vectorstore import VectorStoreSearchResultWithScore


class FakeCache:
    def __init__(self):
        self.store = {}
        self.increments = {}

    def get(self, key: str):
        return self.store.get(key)

    def set(self, key: str, value: str, *, ttl_seconds: int | None = None):
        self.store[key] = value

    def delete(self, *keys: str):
        for key in keys:
            self.store.pop(key, None)

    def increment(self, key: str) -> int:
        self.increments[key] = self.increments.get(key, 0) + 1
        self.store[key] = str(self.increments[key])
        return self.increments[key]


class FakeRepository:
    def __init__(self, memories=None):
        self.memories = {str(memory.id): memory for memory in (memories or [])}
        self.create_calls = 0
        self.update_calls = 0
        self.delete_calls = 0
        self.list_calls = 0

    def create(self, payload: MemoryCreate):
        self.create_calls += 1
        memory = SimpleNamespace(
            id=uuid4(),
            user_id=payload.user_id,
            key=payload.key,
            value=payload.value,
            source=payload.source,
            created_at=datetime.now(UTC),
            updated_at=datetime.now(UTC),
        )
        self.memories[str(memory.id)] = memory
        return memory

    def update(self, memory_id, payload: MemoryUpdate):
        self.update_calls += 1
        memory = self.memories[str(memory_id)]
        if payload.key is not None:
            memory.key = payload.key
        if payload.value is not None:
            memory.value = payload.value
        if payload.source is not None:
            memory.source = payload.source
        memory.updated_at = datetime.now(UTC)
        return memory

    def delete(self, memory_id):
        self.delete_calls += 1
        self.memories.pop(str(memory_id), None)

    def get_by_id(self, memory_id):
        return self.memories.get(str(memory_id))

    def list_by_user(self, user_id, *, limit=None):
        self.list_calls += 1
        items = [memory for memory in self.memories.values() if memory.user_id == user_id]
        items.sort(key=lambda item: item.updated_at, reverse=True)
        if limit is not None:
            return items[:limit]
        return items


class FakeEmbeddingService:
    def __init__(self):
        self.last_text = None

    def generate_embedding(self, text: str):
        self.last_text = text
        return [1.0, 0.0, 0.0]


class FakeVectorStore:
    def __init__(self, results=None):
        self.results = results or []
        self.last_query_kwargs = None
        self.query_calls = 0

    def similarity_search_with_scores(self, *, query_vector, top_k, filters=None):
        self.query_calls += 1
        self.last_query_kwargs = {"query_vector": list(query_vector), "top_k": top_k, "filters": filters}
        return self.results


def _memory(*, user_id, key, value, source="chat", updated_at=None):
    now = updated_at or datetime.now(UTC)
    return MemoryRead(
        id=uuid4(),
        user_id=user_id,
        key=key,
        value=value,
        source=source,
        created_at=now,
        updated_at=now,
    )


def test_list_memories_uses_versioned_cache_invalidation():
    user_id = uuid4()
    repo = FakeRepository([_memory(user_id=user_id, key="one", value="alpha")])
    cache = FakeCache()
    service = MemoryService(repository=repo, cache=cache)

    first = service.list_memories(user_id)
    second = service.list_memories(user_id)
    assert first == second
    assert repo.list_calls == 1

    service.create_memory(MemoryCreate(user_id=user_id, key="two", value="beta", source="chat"))
    third = service.list_memories(user_id)
    assert len(third) == 2
    assert repo.list_calls == 2


def test_retrieve_memories_queries_vector_layer_and_caches_results():
    user_id = uuid4()
    memory = _memory(user_id=user_id, key="favorite_food", value="biryani")
    repo = FakeRepository([memory])
    cache = FakeCache()
    vector_store = FakeVectorStore(
        results=[
            VectorStoreSearchResultWithScore(
                embedding_id="embedding-1",
                metadata={"source_id": str(memory.id), "source_type": "memory", "user_id": str(user_id)},
                score=0.12,
            )
        ]
    )
    service = MemoryService(
        repository=repo,
        cache=cache,
        embedding_service=FakeEmbeddingService(),
        vector_store=vector_store,
    )

    first = service.retrieve_memories("favorite food", user_id=user_id, top_k=1)
    second = service.retrieve_memories("favorite food", user_id=user_id, top_k=1)

    assert len(first) == 1
    assert first == second
    assert first[0].memory.id == memory.id
    assert vector_store.query_calls == 1
    assert vector_store.last_query_kwargs["filters"]["user_id"] == str(user_id)


def test_delete_memory_invalidates_item_cache():
    user_id = uuid4()
    memory = _memory(user_id=user_id, key="travel", value="goa")
    repo = FakeRepository([memory])
    cache = FakeCache()
    service = MemoryService(repository=repo, cache=cache)

    fetched = service.get_memory(memory.id)
    assert fetched.id == memory.id
    assert cache.get(f"memory:item:{memory.id}") is not None

    service.delete_memory(memory.id)

    assert cache.get(f"memory:item:{memory.id}") is None
