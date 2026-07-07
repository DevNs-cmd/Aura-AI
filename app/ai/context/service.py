from __future__ import annotations

from typing import Any

from .pipeline import ContextPipeline
from .schemas import ContextRequest, ContextResponse


class ContextService:
    """Public entry point for building downstream AI context."""

    def __init__(self, pipeline: ContextPipeline) -> None:
        self._pipeline = pipeline


    def get_context(self, request: ContextRequest, db: Any | None = None) -> ContextResponse:
        context = self._pipeline.build_context(request=request, db=db)
        return ContextResponse(context=context)
