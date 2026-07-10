from pathlib import Path
import sys
from uuid import uuid4

ROOT = Path(__file__).resolve().parents[3]
if str(ROOT) not in sys.path:
    sys.path.insert(0, str(ROOT))

from app.ai.chat.pipeline import ChatPipeline
from app.ai.chat.schemas import ChatRequest, ChatResponse
from app.ai.chat.service import ChatService
from app.ai.context.schemas import AIContext, ContextRequest, ConversationContext
from app.ai.llm.schemas import LLMMessage, LLMResponse
from app.ai.prompt.schemas import PromptMessage, PromptOutput


class FakeContextService:
    def __init__(self, context):
        self.context = context
        self.calls = []

    def get_context(self, request, db=None):
        self.calls.append((request, db))
        return self.context


class FakePromptService:
    def __init__(self, response: PromptOutput):
        self.response = response
        self.calls = []

    def get_prompt(self, request, db=None):
        self.calls.append((request, db))
        return self.response


class FakeLLMService:
    def __init__(self, response: LLMResponse):
        self.response = response
        self.calls = []

    def complete(self, request, db=None):
        self.calls.append((request, db))
        return self.response


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


class FakePipeline:
    def __init__(self, response: ChatResponse) -> None:
        self.response = response
        self.calls = []

    def generate_reply(self, request, db=None):
        self.calls.append((request, db))
        return self.response


def test_chat_service_delegates_to_pipeline():
    request = ChatRequest(user_id=uuid4(), query="Hello")
    response = ChatResponse(
        request=request,
        context=AIContext(request=ContextRequest(user_id=request.user_id, query=request.query), conversation=ConversationContext(query=request.query)),
        prompt=PromptOutput(messages=[PromptMessage(role="user", content="Hello")], prompt="Hello", token_count=1, token_budget=10),
        response=LLMResponse(prompt="Hello", messages=[], provider="fake", model="fake-model", content="Hi"),
    )
    pipeline = FakePipeline(response)
    service = ChatService(pipeline=pipeline)

    result = service.generate_reply(request, db="db-session")

    assert pipeline.calls == [(request, "db-session")]
    assert result.response.content == "Hi"


def test_chat_pipeline_orchestrates_context_prompt_llm_memory_and_journal():
    user_id = uuid4()
    request = ChatRequest(user_id=user_id, query="What should I do today?")
    context = AIContext(
        request=ContextRequest(user_id=user_id, query=request.query),
        conversation=ConversationContext(query=request.query),
    )
    prompt = PromptOutput(
        messages=[PromptMessage(role="system", content="system"), PromptMessage(role="user", content=request.query)],
        prompt="system\n\nuser",
        token_count=8,
        token_budget=32,
    )
    llm_response = LLMResponse(
        prompt=prompt.prompt,
        messages=[LLMMessage.model_validate(message.model_dump()) for message in prompt.messages],
        provider="fake",
        model="fake-model",
        content="Keep going.",
    )
    context_service = FakeContextService(context)
    prompt_service = FakePromptService(prompt)
    llm_service = FakeLLMService(llm_response)
    memory_service = FakeMemoryService()
    journal_service = FakeJournalService()
    pipeline = ChatPipeline(
        context_service=context_service,
        prompt_service=prompt_service,
        llm_service=llm_service,
        memory_service=memory_service,
        journal_service=journal_service,
    )

    result = pipeline.generate_reply(request)

    assert result.context == context
    assert result.prompt == prompt
    assert result.response == llm_response
    assert context_service.calls[0][0].query == request.query
    assert prompt_service.calls[0][0].query == request.query
    assert llm_service.calls[0][0].prompt == prompt.prompt
    assert memory_service.calls[0][0].key == "chat:last_assistant_reply"
    assert journal_service.calls[0][1].title == request.query
