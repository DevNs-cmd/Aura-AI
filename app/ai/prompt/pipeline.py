from __future__ import annotations

from collections.abc import Callable
from typing import Any

from pydantic import ValidationError

from app.ai.context.schemas import AIContext, ContextResponse

from .exceptions import PromptBuildError, PromptError, PromptValidationError
from .repository import PromptRepository
from .schemas import PromptInput, PromptMessage, PromptOutput
from .utils import (
    estimate_prompt_tokens,
    normalize_text,
    normalize_messages,
    render_mapping,
    render_section,
    truncate_text,
)


class PromptPipeline:
    def __init__(
        self,
        *,
        context_service: Any,
        repository_factory: Callable[[Any | None], PromptRepository] | None = None,
    ) -> None:
        self._context_service = context_service
        self._repository_factory = repository_factory or PromptRepository

    def build_prompt(self, request: PromptInput | dict[str, Any], db: Any | None = None) -> PromptOutput:
        prompt_request = self._ensure_request(request)
        repository = self._repository_factory(db)
        templates = repository.get_templates()
        context = self._load_context(prompt_request, db)
        sections = self._build_sections(prompt_request, templates, context)
        sections = self._apply_budget(sections, prompt_request.token_budget)
        messages = normalize_messages(
            PromptMessage(role=section["role"], content=section["content"])
            for section in sections
            if normalize_text(section["content"])
        )
        prompt = self._render_prompt(messages)
        return PromptOutput(
            messages=messages,
            prompt=prompt,
            token_count=estimate_prompt_tokens(messages),
            token_budget=prompt_request.token_budget,
        )

    def _ensure_request(self, request: PromptInput | dict[str, Any]) -> PromptInput:
        if isinstance(request, PromptInput):
            return request
        try:
            return PromptInput.model_validate(request)
        except ValidationError as exc:
            raise PromptValidationError("Invalid prompt input") from exc

    def _load_context(self, request: PromptInput, db: Any | None) -> AIContext:
        try:
            payload = self._context_service.get_context(request=request, db=db)
        except PromptError:
            raise
        except Exception as exc:  # noqa: BLE001 - surface as prompt failure
            raise PromptBuildError("Failed to load context for prompt construction") from exc

        if isinstance(payload, ContextResponse):
            return payload.context
        if isinstance(payload, AIContext):
            return payload
        if isinstance(payload, dict) and "context" in payload:
            context = payload["context"]
            if isinstance(context, AIContext):
                return context
            try:
                return AIContext.model_validate(context)
            except ValidationError as exc:
                raise PromptBuildError("Context service returned invalid context payload") from exc
        raise PromptBuildError("Context service returned an unexpected payload")

    def _build_sections(
        self,
        request: PromptInput,
        templates: dict[str, str],
        context: AIContext,
    ) -> list[dict[str, str]]:
        retrieval_section = render_section(
            "Retrieved context",
            self._render_documents(context.retrieval.documents),
        )
        memory_section = render_section(
            "Memory context",
            self._render_memory(context.memory.memories, context.memory.summary),
        )
        journal_section = render_section(
            "Journal insights",
            self._render_journal(context.journal.entries, context.journal.insights, context.journal.summary),
        )

        return [
            {"kind": "system", "role": "system", "content": templates["system_prompt"]},
            {"kind": "developer", "role": "developer", "content": templates["developer_prompt"]},
            {"kind": "retrieval", "role": "developer", "content": retrieval_section},
            {"kind": "memory", "role": "developer", "content": memory_section},
            {"kind": "journal", "role": "developer", "content": journal_section},
            {"kind": "user", "role": "user", "content": normalize_text(request.query) or request.query},
        ]

    def _render_documents(self, documents: list[dict[str, Any]]) -> list[str]:
        lines: list[str] = []
        for document in documents:
            rendered = render_mapping(document)
            if rendered:
                lines.append(rendered)
        return lines

    def _render_memory(self, memories: list[dict[str, Any]], summary: str | None) -> list[str]:
        lines: list[str] = []
        if summary := normalize_text(summary):
            lines.append(f"summary={summary}")
        for memory in memories:
            rendered = render_mapping(memory)
            if rendered:
                lines.append(rendered)
        return lines

    def _render_journal(
        self,
        entries: list[dict[str, Any]],
        insights: list[str],
        summary: str | None,
    ) -> list[str]:
        lines: list[str] = []
        if summary := normalize_text(summary):
            lines.append(f"summary={summary}")
        for insight in insights:
            cleaned = normalize_text(insight)
            if cleaned:
                lines.append(f"insight={cleaned}")
        for entry in entries:
            rendered = render_mapping(entry)
            if rendered:
                lines.append(rendered)
        return lines

    def _apply_budget(self, sections: list[dict[str, str]], token_budget: int) -> list[dict[str, str]]:
        working = [section.copy() for section in sections if normalize_text(section["content"])]
        if estimate_prompt_tokens(self._to_messages(working)) <= token_budget:
            return working

        truncation_order = ["journal", "memory", "retrieval", "developer", "system", "user"]
        for kind in truncation_order:
            if estimate_prompt_tokens(self._to_messages(working)) <= token_budget:
                break

            section = next((item for item in working if item["kind"] == kind), None)
            if section is None:
                continue

            current_tokens = estimate_prompt_tokens(self._to_messages(working))
            excess = current_tokens - token_budget
            if excess <= 0:
                break

            current_content = section["content"]
            section["content"] = truncate_text(current_content, max(1, estimate_prompt_tokens([PromptMessage(role=section["role"], content=current_content)]) - excess))

        # Final pass trims any remaining overflow in a deterministic order.
        while True:
            current_tokens = estimate_prompt_tokens(self._to_messages(working))
            if current_tokens <= token_budget:
                break
            for kind in truncation_order:
                if current_tokens <= token_budget:
                    break
                section = next((item for item in working if item["kind"] == kind), None)
                if section is None:
                    continue
                content_tokens = estimate_prompt_tokens([PromptMessage(role=section["role"], content=section["content"])])
                if content_tokens <= 1:
                    continue
                section["content"] = truncate_text(section["content"], content_tokens - 1)
                current_tokens = estimate_prompt_tokens(self._to_messages(working))
            else:
                break

        return [section for section in working if normalize_text(section["content"])]

    def _to_messages(self, sections: list[dict[str, str]]) -> list[PromptMessage]:
        return [PromptMessage(role=section["role"], content=section["content"]) for section in sections if normalize_text(section["content"])]

    def _render_prompt(self, messages: list[PromptMessage]) -> str:
        return "\n\n".join(f"{message.role.upper()}:\n{message.content}" for message in messages)
