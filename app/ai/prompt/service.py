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

    def get_prompt(self, request: PromptInput | dict[str, Any], db: Any | None = None) -> PromptOutput:
        try:
            return self._pipeline.build_prompt(request=request, db=db)
        except PromptError:
            raise
        except ValidationError as exc:
            raise PromptValidationError("Invalid prompt request") from exc
        except Exception as exc:  # noqa: BLE001 - surface as prompt failure
            raise PromptBuildError("Failed to build prompt") from exc
