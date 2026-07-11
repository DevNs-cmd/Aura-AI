from __future__ import annotations

from collections.abc import Callable
from typing import Any

from pydantic import ValidationError

from app.ai.context.schemas import AIContext, ContextRequest, ContextResponse
from app.ai.journal.schemas import JournalEntryCreate
from app.ai.llm.schemas import LLMResponse
from app.ai.memory.schemas import MemoryCreate
from app.ai.prompt.schemas import PromptInput, PromptOutput
from app.utils.pdf_generator import build_pdf_filename, build_pdf_report

from .exceptions import ChatConfigurationError, ChatPipelineError, ChatValidationError
from .repository import ChatRepository
from .schemas import ChatRequest, ChatResponse
from .utils import build_default_journal_payload, build_default_memory_payloads, build_default_pdf_payload


class _StaticContextService:
    def __init__(self, context: Any) -> None:
        self._context = context

    def get_context(self, request: Any, db: Any | None = None) -> ContextResponse:
        if isinstance(self._context, ContextResponse):
            return self._context
        return ContextResponse(context=self._context)


class ChatPipeline:
    def __init__(
        self,
        *,
        context_service: Any,
        prompt_service: Any,
        llm_service: Any,
        memory_service: Any,
        journal_service: Any,
        repository_factory: Callable[[Any | None], ChatRepository] | None = None,
        memory_payload_factory: Callable[[ChatRequest, LLMResponse], list[MemoryCreate]] | None = None,
        journal_payload_factory: Callable[[ChatRequest, LLMResponse], JournalEntryCreate] | None = None,
        pdf_payload_factory: Callable[[ChatRequest, AIContext, LLMResponse], dict[str, Any] | None] | None = None,
    ) -> None:
        self._context_service = context_service
        self._prompt_service = prompt_service
        self._llm_service = llm_service
        self._memory_service = memory_service
        self._journal_service = journal_service
        self._repository_factory = repository_factory or ChatRepository
        self._memory_payload_factory = memory_payload_factory or build_default_memory_payloads
        self._journal_payload_factory = journal_payload_factory or build_default_journal_payload
        self._pdf_payload_factory = pdf_payload_factory or build_default_pdf_payload

    def generate_reply(self, request: ChatRequest | dict[str, Any], db: Any | None = None) -> ChatResponse:
        chat_request = self._ensure_request(request)
        repository = self._repository_factory(db)
        context = self._load_context(chat_request, repository)
        prompt = self._load_prompt(chat_request, context, repository)
        response = self._load_response(prompt, repository)
        memory_updates, journal_updates = self._persist_follow_up_artifacts(chat_request, response)
        pdf_report_type, pdf_report_filename, pdf_report_bytes = self._maybe_generate_pdf(chat_request, context, response)
        return ChatResponse(
            request=chat_request,
            context=context,
            prompt=prompt,
            response=response,
            memory_updates=memory_updates,
            journal_updates=journal_updates,
            pdf_report_type=pdf_report_type,
            pdf_report_filename=pdf_report_filename,
            pdf_report_bytes=pdf_report_bytes,
        )

    @staticmethod
    def _ensure_request(request: ChatRequest | dict[str, Any]) -> ChatRequest:
        if isinstance(request, ChatRequest):
            return request
        try:
            return ChatRequest.model_validate(request)
        except ValidationError as exc:
            raise ChatValidationError("Invalid chat request") from exc

    def _load_context(self, request: ChatRequest, repository: ChatRepository) -> Any:
        context_request = ContextRequest(
            user_id=request.user_id,
            query=request.query,
            session_id=request.session_id,
            conversation_id=request.conversation_id,
            memory_limit=request.memory_limit,
            journal_limit=request.journal_limit,
            retrieval_limit=request.retrieval_limit,
        )
        try:
            payload = self._context_service.get_context(request=context_request, db=repository.db)
        except Exception as exc:  # noqa: BLE001 - orchestration boundary
            raise ChatPipelineError("Failed to load chat context") from exc

        if isinstance(payload, ContextResponse):
            return payload.context
        if isinstance(payload, AIContext):
            return payload
        if hasattr(payload, "context"):
            context = payload.context
            if isinstance(context, AIContext):
                return context
            return AIContext.model_validate(context)
        if isinstance(payload, dict) and "context" in payload:
            return AIContext.model_validate(payload["context"])
        return payload

    def _load_prompt(self, request: ChatRequest, context: Any, repository: ChatRepository) -> PromptOutput:
        prompt_request = PromptInput(
            user_id=request.user_id,
            query=request.query,
            session_id=request.session_id,
            conversation_id=request.conversation_id,
            memory_limit=request.memory_limit,
            journal_limit=request.journal_limit,
            retrieval_limit=request.retrieval_limit,
            token_budget=request.token_budget,
        )
        try:
            payload = self._prompt_service.get_prompt(
                request=prompt_request,
                db=repository.db,
            )

        except Exception as exc:  # noqa: BLE001 - orchestration boundary
            raise ChatPipelineError("Failed to build chat prompt") from exc


        if isinstance(payload, PromptOutput):

            return payload
        if hasattr(payload, "prompt") and hasattr(payload, "messages"):
            return PromptOutput.model_validate(payload)
        raise ChatPipelineError("Prompt service returned an unexpected payload")

    def _load_response(self, prompt: PromptOutput, repository: ChatRepository) -> LLMResponse:
        try:
            payload = self._llm_service.complete(request=prompt, db=repository.db)
        except Exception as exc:  # noqa: BLE001 - orchestration boundary
            raise ChatPipelineError("Failed to complete chat response") from exc

        if isinstance(payload, LLMResponse):
            return payload
        if hasattr(payload, "content") and hasattr(payload, "provider"):
            return LLMResponse.model_validate(payload)
        raise ChatPipelineError("LLM service returned an unexpected payload")

    def _persist_follow_up_artifacts(self, request: ChatRequest, response: LLMResponse) -> tuple[list[dict[str, Any]], list[dict[str, Any]]]:
        memory_updates: list[dict[str, Any]] = []
        journal_updates: list[dict[str, Any]] = []

        if request.persist_memory:
            memory_payloads = self._memory_payload_factory(request, response)
            if memory_payloads:
                self._memory_service.upsert_memories(memory_payloads)
                memory_updates = [payload.model_dump() for payload in memory_payloads]

        if request.persist_journal:
            journal_payload = self._journal_payload_factory(request, response)
            if journal_payload is not None:
                self._journal_service.create_entry(user_id=request.user_id, payload=journal_payload)
                journal_updates = [journal_payload.model_dump()]

        return memory_updates, journal_updates

    def _maybe_generate_pdf(self, request: ChatRequest, context: Any, response: LLMResponse) -> tuple[str | None, str | None, bytes | None]:
        if not isinstance(context, AIContext):
            return None, None, None

        try:
            payload = self._pdf_payload_factory(request, context, response)
        except Exception as exc:  # noqa: BLE001 - orchestration boundary
            raise ChatPipelineError("Failed to build PDF payload") from exc

        if payload is None:
            return None, None, None

        try:
            pdf_bytes = build_pdf_report(payload)
            report_type = str(payload.get("report_type") or "custom")
            filename = build_pdf_filename(
                str(payload.get("title") or "Aura AI Report"),
                report_type,
                user=str(payload.get("user")) if payload.get("user") is not None else None,
                date_value=payload.get("date"),
            )
        except Exception as exc:  # noqa: BLE001 - orchestration boundary
            raise ChatPipelineError("Failed to generate PDF report") from exc
        return report_type, filename, pdf_bytes


def build_chat_pipeline(
    *,
    context_service: Any | None = None,
    prompt_service: Any | None = None,
    llm_service: Any | None = None,
    memory_service: Any | None = None,
    journal_service: Any | None = None,
    repository_factory: Callable[[Any | None], ChatRepository] | None = None,
    memory_payload_factory: Callable[[ChatRequest, LLMResponse], list[MemoryCreate]] | None = None,
    journal_payload_factory: Callable[[ChatRequest, LLMResponse], JournalEntryCreate] | None = None,
    pdf_payload_factory: Callable[[ChatRequest, AIContext, LLMResponse], dict[str, Any] | None] | None = None,
) -> ChatPipeline:
    if context_service is None:
        raise ChatConfigurationError("A context service is required to build the chat pipeline")
    if prompt_service is None:
        raise ChatConfigurationError("A prompt service is required to build the chat pipeline")
    if llm_service is None:
        raise ChatConfigurationError("An LLM service is required to build the chat pipeline")
    if memory_service is None:
        raise ChatConfigurationError("A memory service is required to build the chat pipeline")
    if journal_service is None:
        raise ChatConfigurationError("A journal service is required to build the chat pipeline")

    return ChatPipeline(
        context_service=context_service,
        prompt_service=prompt_service,
        llm_service=llm_service,
        memory_service=memory_service,
        journal_service=journal_service,
        repository_factory=repository_factory,
        memory_payload_factory=memory_payload_factory,
        journal_payload_factory=journal_payload_factory,
        pdf_payload_factory=pdf_payload_factory,
    )
