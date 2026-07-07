from pathlib import Path
import sys
from uuid import uuid4

ROOT = Path(__file__).resolve().parents[3]
if str(ROOT) not in sys.path:
    sys.path.insert(0, str(ROOT))

from app.ai.context.pipeline import ContextPipeline
from app.ai.context.schemas import AIContext, ContextRequest, ConversationContext, MemoryContext
from app.ai.context.service import ContextService


class FakePipeline:
    def __init__(self) -> None:
        self.calls = []

    def build_context(self, request, db=None):
        self.calls.append((request, db))
        return AIContext(
            request=request,
            conversation=ConversationContext(query=request.query),
            memory=MemoryContext(memories=[{"key": "mood", "value": "calm"}]),
        )


def test_context_service_delegates_to_pipeline():
    pipeline = FakePipeline()
    service = ContextService(pipeline=pipeline)
    request = ContextRequest(user_id=uuid4(), query="How am I doing?")

    response = service.get_context(request, db="db-session")

    assert pipeline.calls == [(request, "db-session")]
    assert response.context.memory.memories == [{"key": "mood", "value": "calm"}]


def test_context_pipeline_merges_service_outputs():
    def memory_service(**kwargs):
        return {"memories": [{"key": "favorite_food", "value": "biryani"}], "summary": "memory"}

    def journal_service(**kwargs):
        return {"entries": [{"title": "Reflection", "content": "Feeling good"}], "insights": ["steady"], "summary": "journal"}

    def rag_service(**kwargs):
        return {"documents": [{"source": "doc-1", "content": "retrieved"}], "summary": "retrieval"}

    pipeline = ContextPipeline(
        memory_service=memory_service,
        journal_service=journal_service,
        rag_service=rag_service,
    )
    request = ContextRequest(user_id=uuid4(), query="What do you know about me?", memory_limit=3)

    context = pipeline.build_context(request)

    assert context.conversation.query == request.query
    assert context.memory.memories == [{"key": "favorite_food", "value": "biryani"}]
    assert context.memory.summary == "memory"
    assert context.journal.entries == [{"title": "Reflection", "content": "Feeling good"}]
    assert context.journal.insights == ["steady"]
    assert context.journal.summary == "journal"
    assert context.retrieval.documents == [{"source": "doc-1", "content": "retrieved"}]
    assert context.retrieval.summary == "retrieval"


def test_context_pipeline_normalizes_list_payloads():
    pipeline = ContextPipeline(
        memory_service=lambda **kwargs: [{"key": "timezone", "value": "IST"}],
        journal_service=lambda **kwargs: ["note-one"],
        rag_service=lambda **kwargs: ["chunk-one"],
    )
    request = ContextRequest(user_id=uuid4(), query="Normalize payloads")

    context = pipeline.build_context(request)

    assert context.memory.memories == [{"key": "timezone", "value": "IST"}]
    assert context.journal.entries == [{"value": "note-one"}]
    assert context.retrieval.documents == [{"value": "chunk-one"}]
