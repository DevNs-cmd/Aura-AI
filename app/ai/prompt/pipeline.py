from __future__ import annotations

from collections.abc import Callable
from typing import Any

from pydantic import ValidationError

from app.ai.context.schemas import AIContext, ContextRequest, ContextResponse



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

        # Re-check and iteratively enforce token-budget on the final message list.
        # This restores the guarantee even if section-level truncation is imperfect.
        messages = normalize_messages(
            PromptMessage(role=section["role"], content=section["content"])
            for section in sections
            if normalize_text(section["content"])
        )

        token_budget = prompt_request.token_budget
        # Deterministic trimming loop: keep trimming until within budget.
        truncation_order = ["journal", "memory", "retrieval", "developer", "system", "user"]
        while estimate_prompt_tokens(messages) > token_budget:
            working_sections = [s for s in sections if normalize_text(s["content"])]
            current_tokens = estimate_prompt_tokens(messages)
            excess = current_tokens - token_budget
            if excess <= 0:
                break

            trimmed_any = False
            for kind in truncation_order:
                if estimate_prompt_tokens(messages) <= token_budget:
                    break

                section = next((s for s in working_sections if s["kind"] == kind), None)
                if section is None:
                    continue

                role = section["role"]
                content = section["content"]
                content_tokens = estimate_prompt_tokens([PromptMessage(role=role, content=content)])
                if content_tokens <= 1:
                    continue

                # Trim deterministically: reduce estimated content tokens by at least the excess.
                target = max(1, content_tokens - max(1, excess))
                new_content = truncate_text(content, target)
                if new_content != content:
                    section["content"] = new_content
                    trimmed_any = True

                messages = normalize_messages(
                    PromptMessage(role=s["role"], content=s["content"]) for s in working_sections if normalize_text(s["content"])
                )

            if not trimmed_any:
                break


        prompt = self._render_prompt(messages)
        return PromptOutput(
            messages=messages,
            prompt=prompt,
            token_count=estimate_prompt_tokens(messages),
            token_budget=token_budget,
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
            # Build downstream ContextRequest explicitly (do not pass PromptInput directly)
            context_request = ContextRequest(
                user_id=request.user_id,
                query=request.query,
                session_id=request.session_id,
                conversation_id=request.conversation_id,
                memory_limit=request.memory_limit,
                journal_limit=request.journal_limit,
                retrieval_limit=request.retrieval_limit,
            )
            payload = self._context_service.get_context(request=context_request, db=db)




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
        # Render memory exactly from context. Do not let budget logic drop it for small prompts.
        memory_lines = self._render_memory(context.memory.memories, context.memory.summary)
        memory_section = render_section("Memory context", memory_lines)


        journal_section = render_section(
            "Journal insights",
            self._render_journal(context.journal.entries, context.journal.insights, context.journal.summary),
        )

        # Preserve existing architecture: render sections in fixed order.
        # Also preserve deterministically that non-empty sections are included.
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
            # Special-case the common memory schema: {"key": ..., "value": ...}
            # Tests expect it to render as: key=value (e.g. language=Python).
            if isinstance(memory, dict) and "key" in memory and "value" in memory:
                key_text = normalize_text(memory.get("key"))
                value_text = normalize_text(memory.get("value"))
                if key_text and value_text:
                    lines.append(f"{key_text}={value_text}")
                    continue

            rendered = render_mapping(memory)
            if rendered:
                lines.append(rendered)
                continue

            # Last resort: render any scalar dict values as key=value.
            if isinstance(memory, dict) and memory:
                try:
                    key_text = normalize_text(next(iter(memory.keys())))
                    value_text = normalize_text(next(iter(memory.values())))
                except Exception:  # noqa: BLE001
                    key_text = None
                    value_text = None
                if key_text and value_text:
                    lines.append(f"{key_text}={value_text}")


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
        working = [section.copy() for section in sections if normalize_text(section["content"]) ]
        if estimate_prompt_tokens(self._to_messages(working)) <= token_budget:
            return working

        # Deterministic iterative trimming until within budget.
        # Preserve memory content whenever possible to keep required context.
        truncation_order = ["journal", "retrieval", "developer", "system", "user", "memory"]

        while estimate_prompt_tokens(self._to_messages(working)) > token_budget:
            trimmed_in_pass = False

            for kind in truncation_order:
                if estimate_prompt_tokens(self._to_messages(working)) <= token_budget:
                    return [section for section in working if normalize_text(section["content"])]

                section = next((item for item in working if item["kind"] == kind), None)
                if section is None:
                    continue

                current_content = section["content"]
                if not normalize_text(current_content):
                    continue

                # Token estimate for this section alone.
                section_tokens = estimate_prompt_tokens(
                    [PromptMessage(role=section["role"], content=current_content)]
                )
                if section_tokens <= 1:
                    continue

                # Reduce by at least 1 estimated token each step.
                next_token_budget = max(1, section_tokens - 1)
                new_content = truncate_text(current_content, next_token_budget)

                if new_content != current_content:
                    section["content"] = new_content
                    trimmed_in_pass = True

            if not trimmed_in_pass:
                break

        return [section for section in working if normalize_text(section["content"])]



    def _to_messages(self, sections: list[dict[str, str]]) -> list[PromptMessage]:
        return [PromptMessage(role=section["role"], content=section["content"]) for section in sections if normalize_text(section["content"])]

    def _render_prompt(self, messages: list[PromptMessage]) -> str:
        return "\n\n".join(f"{message.role.upper()}:\n{message.content}" for message in messages)
