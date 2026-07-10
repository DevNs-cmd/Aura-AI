from pathlib import Path
import sys
from uuid import uuid4

ROOT = Path(__file__).resolve().parents[3]
if str(ROOT) not in sys.path:
    sys.path.insert(0, str(ROOT))

from app.ai.chat.pipeline import ChatPipeline
from app.ai.chat.service import ChatService
from app.ai.context.pipeline import ContextPipeline
from app.ai.context.service import ContextService
from app.ai.context.schemas import ContextRequest
from app.ai.llm.pipeline import LLMPipeline
from app.ai.llm.schemas import LLMMessage, LLMResponse
from app.ai.llm.service import LLMService
from app.ai.prompt.pipeline import PromptPipeline
from app.ai.prompt.service import PromptService
from app.ai.chat.schemas import ChatRequest
from app.ai.prompt.schemas import PromptOutput


class FakeMemoryService:
    def __init__(self):
        self.calls = []

    def upsert_memories(self, payloads):
        self.calls.append(list(payloads))


class FakeJournalService:
    def __init__(self):
        self.calls = []

    def create_entry(self, *, user_id, payload):
        self.calls.append((user_id, payload))
        return payload


class FakeLLMRepository:
    provider_name = "fake-provider"
    model_name = "fake-model"

    def complete(self, *, messages, prompt, model=None, temperature=None, max_tokens=None, timeout_seconds=30, metadata=None):
        return {
            "provider": self.provider_name,
            "model": model or self.model_name,
            "choices": [
                {
                    "message": {"content": "Absolutely."},
                    "finish_reason": "stop",
                }
            ],
            "usage": {"prompt_tokens": 15, "completion_tokens": 5, "total_tokens": 20},
        }


def test_chat_service_end_to_end_with_real_prompt_and_context_services():
    user_id = uuid4()
    context_pipeline = ContextPipeline(
        memory_service=lambda **kwargs: {"memories": [{"key": "goal", "value": "stay focused"}], "summary": "memory"},
        journal_service=lambda **kwargs: {"entries": [{"title": "Day 1", "content": "Started"}], "insights": ["steady"], "summary": "journal"},
        rag_service=lambda **kwargs: {"documents": [{"source": "kb", "content": "Useful context"}], "summary": "retrieval"},
    )
    context_service = ContextService(pipeline=context_pipeline)
    prompt_pipeline = PromptPipeline(context_service=context_service)
    prompt_service = PromptService(pipeline=prompt_pipeline)
    llm_service = LLMService(pipeline=LLMPipeline(repository=FakeLLMRepository(), sleeper=lambda seconds: None))
    memory_service = FakeMemoryService()
    journal_service = FakeJournalService()
    chat_pipeline = ChatPipeline(
        context_service=context_service,
        prompt_service=prompt_service,
        llm_service=llm_service,
        memory_service=memory_service,
        journal_service=journal_service,
    )
    service = ChatService(pipeline=chat_pipeline)
    request = ChatRequest(
        user_id=user_id,
        query="What should I focus on next?",
        session_id=uuid4(),
        memory_limit=3,
        journal_limit=3,
        retrieval_limit=3,
        token_budget=512,
    )

    response = service.generate_reply(request)

    assert response.context.request == ContextRequest(
        user_id=user_id,
        query=request.query,
        session_id=request.session_id,
        conversation_id=None,
        memory_limit=3,
        journal_limit=3,
        retrieval_limit=3,
    )
    assert response.prompt.messages[-1].content == request.query
    assert response.response.content == "Absolutely."
    assert memory_service.calls[0][0].value == "Absolutely."
    assert journal_service.calls[0][1].content == "Absolutely."
