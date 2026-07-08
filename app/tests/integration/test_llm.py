from pathlib import Path
import sys

ROOT = Path(__file__).resolve().parents[3]
if str(ROOT) not in sys.path:
    sys.path.insert(0, str(ROOT))

from app.ai.llm.pipeline import LLMPipeline
from app.ai.llm.schemas import LLMMessage, LLMRequest
from app.ai.llm.service import LLMService


class FakeRepository:
    provider_name = "fake-provider"
    model_name = "fake-model"

    def complete(self, *, messages, prompt, model=None, temperature=None, max_tokens=None, timeout_seconds=30, metadata=None):
        return {
            "provider": self.provider_name,
            "model": model or self.model_name,
            "choices": [
                {
                    "message": {"content": f"echo: {prompt}"},
                    "finish_reason": "stop",
                }
            ],
            "usage": {"prompt_tokens": 7, "completion_tokens": 3, "total_tokens": 10},
        }


def test_llm_service_end_to_end_with_prompt_request():
    pipeline = LLMPipeline(repository=FakeRepository(), sleeper=lambda seconds: None)
    service = LLMService(pipeline=pipeline)
    request = LLMRequest(
        prompt="Build a reply.",
        messages=[LLMMessage(role="user", content="Build a reply.")],
        model="fake-model",
    )

    response = service.complete(request)

    assert response.provider == "fake-provider"
    assert response.content == "echo: Build a reply."
    assert response.usage is not None
    assert response.usage.prompt_tokens == 7
