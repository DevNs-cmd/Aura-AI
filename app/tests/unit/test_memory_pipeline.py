from __future__ import annotations

from datetime import datetime, timezone
UTC = timezone.utc
from types import SimpleNamespace
from uuid import uuid4

import pytest

from app.ai.embeddings.exceptions import EmbeddingProviderError
from app.ai.memory.pipeline import MemoryPipeline
from app.ai.memory.schemas import MemoryCreate, MemoryRead, MemoryUpdate


class FakeService:
    def __init__(self):
        self.created = []
        self.updated = []
        self.deleted = []
        self.memories = {}

    def create_memory(self, payload: MemoryCreate):
        memory = MemoryRead(
            id=uuid4(),
            user_id=payload.user_id,
            key=payload.key,
            value=payload.value,
            source=payload.source,
            created_at=datetime.now(UTC),
            updated_at=datetime.now(UTC),
        )
        self.created.append(payload)
        self.memories[str(memory.id)] = memory
        return memory

    def update_memory(self, memory_id, payload: MemoryUpdate):
        self.updated.append((memory_id, payload))
        existing = self.memories[str(memory_id)]
        memory = MemoryRead(
            id=existing.id,
            user_id=existing.user_id,
            key=payload.key or existing.key,
            value=payload.value or existing.value,
            source=payload.source or existing.source,
            created_at=existing.created_at,
            updated_at=datetime.now(UTC),
        )
        self.memories[str(memory_id)] = memory
        return memory

    def delete_memory(self, memory_id):
        self.deleted.append(memory_id)
        self.memories.pop(str(memory_id), None)

    def get_memory(self, memory_id):
        return self.memories[str(memory_id)]

    def list_memories(self, user_id, *, limit=None):
        return list(self.memories.values())

    def retrieve_memories(self, *args, **kwargs):
        return []


class FakeEmbeddingPipeline:
    def __init__(self, *, fail: bool = False):
        self.fail = fail
        self.calls = []

    def generate_embedding(self, text: str, *, persist: bool, source_type: str, source_id: str, metadata: dict):
        self.calls.append(
            {
                "text": text,
                "persist": persist,
                "source_type": source_type,
                "source_id": source_id,
                "metadata": metadata,
            }
        )
        if self.fail:
            raise EmbeddingProviderError("boom")
        return [1.0, 0.0, 0.0]


def test_pipeline_creates_memory_and_indexes_it():
    service = FakeService()
    embedding_pipeline = FakeEmbeddingPipeline()
    pipeline = MemoryPipeline(service=service, embedding_pipeline=embedding_pipeline)
    user_id = uuid4()

    memory = pipeline.create_memory(MemoryCreate(user_id=user_id, key="favorite_food", value="biryani", source="chat"))

    assert memory.key == "favorite_food"
    assert service.created
    assert embedding_pipeline.calls[0]["source_type"] == "memory"
    assert embedding_pipeline.calls[0]["metadata"]["user_id"] == str(user_id)


def test_pipeline_rolls_back_memory_when_indexing_fails():
    service = FakeService()
    embedding_pipeline = FakeEmbeddingPipeline(fail=True)
    pipeline = MemoryPipeline(service=service, embedding_pipeline=embedding_pipeline)
    user_id = uuid4()

    with pytest.raises(Exception):
        pipeline.create_memory(MemoryCreate(user_id=user_id, key="travel", value="goa", source="chat"))

    assert service.deleted
