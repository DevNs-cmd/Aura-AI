from pathlib import Path
import sys
from uuid import uuid4

from fastapi.testclient import TestClient

ROOT = Path(__file__).resolve().parents[3]
if str(ROOT) not in sys.path:
    sys.path.insert(0, str(ROOT))

from app.api.deps import get_ai_chat_service, get_db
from app.ai.chat.schemas import ChatRequest, ChatResponse
from app.ai.context.schemas import AIContext, ContextRequest, ConversationContext, MemoryContext, RetrievalContext
from app.ai.llm.schemas import LLMResponse
from app.ai.prompt.schemas import PromptOutput
from app.main import app
from app.models.user import User


class FakeQuery:
    def __init__(self, user):
        self.user = user

    def filter(self, *args, **kwargs):
        return self

    def first(self):
        return self.user


class FakeDB:
    def __init__(self, user):
        self.user = user

    def query(self, model):
        assert model is User
        return FakeQuery(self.user)


class FakeChatService:
    def __init__(self, response: ChatResponse):
        self.response = response
        self.calls = []

    def generate_reply(self, request, db=None):
        self.calls.append((request, db))
        return self.response


def test_ai_chat_route_is_registered_and_returns_structured_response():
    user_id = uuid4()
    request = ChatRequest(user_id=user_id, query="Hello Aura")
    context = AIContext(
        request=ContextRequest(user_id=user_id, query=request.query),
        conversation=ConversationContext(query=request.query),
        memory=MemoryContext(memories=[{"key": "tone", "value": "calm"}]),
        retrieval=RetrievalContext(documents=[{"source": "kb", "content": "Helpful context"}]),
    )
    response = ChatResponse(
        request=request,
        context=context,
        prompt=PromptOutput(messages=[], prompt="Prompt", token_count=1, token_budget=8),
        response=LLMResponse(prompt="Prompt", messages=[], provider="openrouter", model="test-model", content="Hi there!"),
    )
    fake_service = FakeChatService(response)
    fake_user = User(id=user_id, email="user@example.com", hashed_password="hash", is_active=True)

    app.dependency_overrides[get_db] = lambda: FakeDB(fake_user)
    app.dependency_overrides[get_ai_chat_service] = lambda: fake_service

    try:
        client = TestClient(app)

        paths = {route.path for route in app.routes}
        assert "/ai/chat" in paths
        assert "/api/v1/chat/sessions" in paths

        result = client.post("/ai/chat", json={"user_id": str(user_id), "message": "Hello Aura"})

        assert result.status_code == 200
        payload = result.json()
        assert payload["reply"] == "Hi there!"
        assert payload["model_used"] == "test-model"
        assert payload["metadata"] == {"memory_used": True, "rag_used": True}
        assert "timestamp" in payload
        assert fake_service.calls[0][0].user_id == user_id
        assert fake_service.calls[0][0].query == "Hello Aura"
    finally:
        app.dependency_overrides.clear()
