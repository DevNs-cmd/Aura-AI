from pathlib import Path
import sys
from uuid import uuid4

ROOT = Path(__file__).resolve().parents[3]
if str(ROOT) not in sys.path:
    sys.path.insert(0, str(ROOT))

from app.ai.context.pipeline import ContextPipeline
from app.ai.context.schemas import ContextRequest
from app.ai.context.service import ContextService


def test_context_service_end_to_end_with_injected_dependencies():
    pipeline = ContextPipeline(
        memory_service=lambda **kwargs: {"memories": [{"key": "language", "value": "Python"}]},
        journal_service=lambda **kwargs: {"entries": [{"title": "Day 1", "content": "Started"}], "insights": ["consistent"]},
        rag_service=lambda **kwargs: {"documents": [{"source": "kb", "content": "Context docs"}]},
    )
    service = ContextService(pipeline=pipeline)
    request = ContextRequest(
        user_id=uuid4(),
        query="Build me a context object.",
        session_id=uuid4(),
    )

    response = service.get_context(request)

    assert response.context.request == request
    assert response.context.conversation.session_id == request.session_id
    assert response.context.memory.memories == [{"key": "language", "value": "Python"}]
    assert response.context.journal.entries == [{"title": "Day 1", "content": "Started"}]
    assert response.context.journal.insights == ["consistent"]
    assert response.context.retrieval.documents == [{"source": "kb", "content": "Context docs"}]
