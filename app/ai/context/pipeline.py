from __future__ import annotations

from collections.abc import Callable
from typing import Any

from .exceptions import ContextPipelineError
from .repository import ContextRepository
from .schemas import (
    AIContext,
    ContextRequest,
    ConversationContext,
    JournalContext,
    MemoryContext,
    RetrievalContext,
)
from .utils import build_call_kwargs, normalize_text, to_dict_list



class ContextPipeline:
    def __init__(
        self,
        *,
        memory_service: Any,
        journal_service: Any,
        rag_service: Any,
        repository_factory: Callable[[Any | None], ContextRepository] | None = None,
    ) -> None:
        self._memory_service = memory_service
        self._journal_service = journal_service
        self._rag_service = rag_service
        self._repository_factory = repository_factory or ContextRepository


    def build_context(self, request: ContextRequest, db: Any | None = None) -> AIContext:
        repository = self._repository_factory(db)
        conversation = ConversationContext(
            query=request.query,
            session_id=request.session_id,
        )
        memory = self._build_memory_context(request, repository)
        journal = self._build_journal_context(request, repository)
        retrieval = self._build_retrieval_context(request, repository)
        return AIContext(
            request=request,
            conversation=conversation,
            memory=memory,
            journal=journal,
            retrieval=retrieval,
        )

    def _build_memory_context(
        self, request: ContextRequest, repository: ContextRepository
    ) -> MemoryContext:
        payload = self._call_service(
            self._memory_service,
            request=request,
            db=repository.db,
            query=request.query,
            limit=request.memory_limit,
        )

        if isinstance(payload, MemoryContext):
            return payload
        if payload is None:
            return MemoryContext()
        if isinstance(payload, dict):
            return MemoryContext(
                memories=to_dict_list(payload),
                summary=normalize_text(payload.get("summary")),
            )
        return MemoryContext(memories=to_dict_list(payload))

    def _build_journal_context(
        self, request: ContextRequest, repository: ContextRepository
    ) -> JournalContext:
        payload = self._call_service(
            self._journal_service,
            request=request,
            db=repository.db,
            query=request.query,
            limit=request.journal_limit,
        )

        if isinstance(payload, JournalContext):
            return payload
        if payload is None:
            return JournalContext()
        if isinstance(payload, dict):
            return JournalContext(
                entries=to_dict_list(payload),
                insights=[
                    str(item).strip()
                    for item in payload.get("insights", [])
                    if normalize_text(item)
                ],
                summary=normalize_text(payload.get("summary")),
            )
        return JournalContext(entries=to_dict_list(payload))

    def _build_retrieval_context(
        self, request: ContextRequest, repository: ContextRepository
    ) -> RetrievalContext:
        payload = self._call_service(
            self._rag_service,
            request=request,
            db=repository.db,
            query=request.query,
            limit=request.retrieval_limit,
            top_k=request.retrieval_limit,
        )

        if isinstance(payload, RetrievalContext):
            return payload
        if payload is None:
            return RetrievalContext(query=request.query)
        if isinstance(payload, dict):
            return RetrievalContext(
                documents=to_dict_list(payload),
                query=normalize_text(payload.get("query")) or request.query,
                summary=normalize_text(payload.get("summary")),
            )
        return RetrievalContext(documents=to_dict_list(payload), query=request.query)

    def _call_service(self, service: Any, **values: Any) -> Any:
        """Call an injected upstream service.

        Context orchestration must not perform dynamic discovery/import.
        """

        candidate = service
        if hasattr(candidate, "build_context") and callable(candidate.build_context):
            candidate = candidate.build_context
        elif hasattr(candidate, "get_context") and callable(candidate.get_context):
            candidate = candidate.get_context

        kwargs = build_call_kwargs(candidate, values)
        try:
            return candidate(**kwargs) if kwargs else candidate()
        except TypeError as exc:
            raise ContextPipelineError("Failed to call injected context service") from exc

