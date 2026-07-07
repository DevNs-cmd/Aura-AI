from pathlib import Path
import sys
from uuid import uuid4

ROOT = Path(__file__).resolve().parents[3]
if str(ROOT) not in sys.path:
    sys.path.insert(0, str(ROOT))

from app.ai.context.pipeline import ContextPipeline
from app.ai.context.schemas import ContextRequest
from app.ai.context.service import ContextService
from app.ai.prompt.pipeline import PromptPipeline
from app.ai.prompt.schemas import PromptInput
from app.ai.prompt.service import PromptService


def test_prompt_service_end_to_end_with_context_service():
    pipeline = ContextPipeline(
        memory_service=lambda **kwargs: {"memories": [{"key": "language", "value": "Python"}], "summary": "memory"},
        journal_service=lambda **kwargs: {"entries": [{"title": "Day 1", "content": "Started"}], "insights": ["consistent"], "summary": "journal"},
        rag_service=lambda **kwargs: {"documents": [{"source": "kb", "content": "Context docs"}], "summary": "retrieval"},
    )
    context_service = ContextService(pipeline=pipeline)
    prompt_pipeline = PromptPipeline(context_service=context_service)
    service = PromptService(pipeline=prompt_pipeline)
    request = PromptInput(
        user_id=uuid4(),
        query="Build me a prompt.",
        session_id=uuid4(),
        memory_limit=3,
        journal_limit=3,
        retrieval_limit=3,
        token_budget=2000,
    )

    response = service.get_prompt(request)

    assert response.messages[0].role == "system"
    assert response.messages[-1].role == "user"
    assert response.messages[-1].content == request.query
    assert "language=Python" in response.prompt
    assert "consistent" in response.prompt
    assert "Context docs" in response.prompt
