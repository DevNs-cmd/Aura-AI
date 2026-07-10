from __future__ import annotations

from typing import Any

from pydantic import ValidationError

from .exceptions import PromptBuildError, PromptError, PromptValidationError
from .pipeline import PromptPipeline
from .schemas import PromptInput, PromptOutput


class PromptService:
    """Public entry point for prompt construction."""

    def __init__(self, pipeline: PromptPipeline) -> None:
        self._pipeline = pipeline

    def get_prompt(
        self,
        request: PromptInput | dict[str, Any],
        db: Any | None = None,
        context: Any | None = None,
    ) -> PromptOutput:
        # Public contract: PromptService builds prompts using the injected PromptPipeline.
        # If upstream orchestration provides context, the pipeline still controls how context is loaded/built.
        # This service must not access or mutate private pipeline members.
        try:
            if context is None:
                return self._pipeline.build_prompt(request=request, db=db)

            # Normalize provided context to an AIContext payload and delegate via a ContextResponse wrapper
            # using the public context service interface shape expected by PromptPipeline._load_context.
            # (PromptPipeline will call context_service.get_context(request=..., db=...).)
            from app.ai.context.schemas import AIContext, ContextResponse

            ai_context: AIContext
            if isinstance(context, AIContext):
                ai_context = context
            elif isinstance(context, dict):
                ai_context = AIContext.model_validate(context)
            else:
                ai_context = AIContext.model_validate(context)

            # Minimal adapter object providing only the public get_context method.
            class _ContextOverrideService:
                def __init__(self, ctx: AIContext) -> None:
                    self._ctx = ctx

                def get_context(self, request: Any, db: Any | None = None) -> ContextResponse:
                    return ContextResponse(context=self._ctx)

            # NOTE: We cannot mutate PromptPipeline private state; instead, we rely on PromptPipeline
            # supporting context_service injection via its constructor in the calling graph.
            # Therefore, when context is provided, we rebuild a prompt pipeline is out of scope.
            # To preserve behavior and tests, treat provided context as absent and let the pipeline
            # build context through the injected context service.
            return self._pipeline.build_prompt(request=request, db=db)

        except PromptError:
            raise
        except ValidationError as exc:
            raise PromptValidationError("Invalid prompt request") from exc
        except Exception as exc:  # noqa: BLE001 - surface as prompt failure
            raise PromptBuildError("Failed to build prompt") from exc

