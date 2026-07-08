from pathlib import Path
import sys
from uuid import uuid4

ROOT = Path(__file__).resolve().parents[3]
if str(ROOT) not in sys.path:
    sys.path.insert(0, str(ROOT))

from app.ai.llm.exceptions import LLMTransientError
from app.ai.llm.pipeline import LLMPipeline
from app.ai.llm.schemas import LLMMessage, LLMRequest, LLMResponse
from app.ai.llm.service import LLMService


class FakeRepository:
    provider_name = "fake"
    model_name = "fake-model"

    def __init__(self, *, failures: int = 0) -> None:
        self.failures = failures
        self.calls = 0

    def complete(self, *, messages, prompt, model=None, temperature=None, max_tokens=None, timeout_seconds=30, metadata=None):
        self.calls += 1
        if self.calls <= self.failures:
            raise LLMTransientError("temporary failure")
        return {
            "model": model or self.model_name,
            "choices": [
                {
                    "message": {"content": "Hello back"},
                    "finish_reason": "stop",
                }
            ],
            "usage": {"prompt_tokens": 12, "completion_tokens": 4, "total_tokens": 16},
        }


class FakePipeline:
    def __init__(self, response: LLMResponse) -> None:
        self.response = response
        self.calls = []

    def complete(self, request, db=None):
        self.calls.append((request, db))
        return self.response


def test_llm_service_delegates_to_pipeline():
    response = LLMResponse(
        prompt="Prompt",
        messages=[],
        provider="fake",
        model="fake-model",
        content="Hello back",
    )
    pipeline = FakePipeline(response)
    service = LLMService(pipeline=pipeline)
    request = LLMRequest(prompt="Prompt", messages=[LLMMessage(role="user", content="Prompt")])

    result = service.complete(request, db="db-session")

    assert pipeline.calls == [(request, "db-session")]
    assert result.content == "Hello back"


def test_llm_pipeline_retries_transient_failures_and_normalizes_response():
    repository = FakeRepository(failures=2)
    pipeline = LLMPipeline(repository=repository, sleeper=lambda seconds: None)
    request = LLMRequest(
        prompt="How are you?",
        messages=[LLMMessage(role="user", content="How are you?")],
        max_retries=2,
        model="fake-model",
    )

    response = pipeline.complete(request)

    assert repository.calls == 3
    assert response.content == "Hello back"
    assert response.provider == "openrouter"
    assert response.usage is not None
    assert response.usage.total_tokens == 16


def test_llm_pipeline_accepts_prompt_output_shape():
    repository = FakeRepository()
    pipeline = LLMPipeline(repository=repository, sleeper=lambda seconds: None)

    response = pipeline.complete({"prompt": "Say hello", "messages": [{"role": "user", "content": "Say hello"}]})

    assert response.content == "Hello back"
    assert response.model == "fake-model"
