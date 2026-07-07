from pathlib import Path
import sys
from uuid import uuid4

ROOT = Path(__file__).resolve().parents[3]
if str(ROOT) not in sys.path:
    sys.path.insert(0, str(ROOT))

from app.ai.context.schemas import (
    AIContext,
    ContextRequest,
    ConversationContext,
    JournalContext,
    MemoryContext,
    RetrievalContext,
)
from app.ai.prompt.pipeline import PromptPipeline
from app.ai.prompt.schemas import PromptInput, PromptOutput
from app.ai.prompt.service import PromptService


class FakeContextService:
    def __init__(self, context):
        self.context = context
        self.calls = []

    def get_context(self, request, db=None):
        self.calls.append((request, db))
        return self.context


class FakePipeline:
    def __init__(self) -> None:
        self.calls = []

    def build_prompt(self, request, db=None):
        self.calls.append((request, db))
        return PromptOutput(messages=[], prompt="prompt", token_count=1, token_budget=10)


def test_prompt_service_delegates_to_pipeline():
    pipeline = FakePipeline()
    service = PromptService(pipeline=pipeline)
    request = PromptInput(user_id=uuid4(), query="How am I doing?")

    response = service.get_prompt(request, db="db-session")

    assert pipeline.calls == [(request, "db-session")]
    assert response.prompt == "prompt"


def test_prompt_pipeline_assembles_prompt_sections_in_order():
    context = AIContext(
        request=ContextRequest(user_id=uuid4(), query="What should I do today?"),
        conversation=ConversationContext(query="What should I do today?"),
        memory=MemoryContext(memories=[{"key": "mood", "value": "calm"}], summary="steady"),
        journal=JournalContext(entries=[{"title": "Reflection", "content": "Stay focused"}], insights=["sleep well"], summary="journal note"),
        retrieval=RetrievalContext(documents=[{"source": "doc-1", "content": "retrieved fact"}], query="What should I do today?"),
    )
    pipeline = PromptPipeline(context_service=FakeContextService(context))
    request = PromptInput(user_id=uuid4(), query="What should I do today?", token_budget=1000)

    output = pipeline.build_prompt(request)

    assert [message.role for message in output.messages] == [
        "system",
        "developer",
        "developer",
        "developer",
        "developer",
        "user",
    ]
    assert "Aura, a helpful and warm personal AI companion." in output.messages[0].content
    assert "Use the supplied context" in output.messages[1].content
    assert "Retrieved context" in output.messages[2].content
    assert "Memory context" in output.messages[3].content
    assert "Journal insights" in output.messages[4].content
    assert output.messages[-1].content == request.query


def test_prompt_pipeline_truncates_to_budget():
    huge_document = "x" * 4000
    context = AIContext(
        request=ContextRequest(user_id=uuid4(), query="Short query"),
        conversation=ConversationContext(query="Short query"),
        memory=MemoryContext(memories=[{"key": "timezone", "value": "IST"}]),
        journal=JournalContext(insights=["consistent"]),
        retrieval=RetrievalContext(documents=[{"source": "kb", "content": huge_document}], query="Short query"),
    )
    pipeline = PromptPipeline(context_service=FakeContextService(context))
    request = PromptInput(user_id=uuid4(), query="Short query", token_budget=120)

    output = pipeline.build_prompt(request)

    assert output.token_count <= request.token_budget
    assert output.messages[-1].content == "Short query"
    assert "Retrieved context" in output.prompt
