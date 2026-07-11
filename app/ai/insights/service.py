from __future__ import annotations

from typing import Any

from pydantic import ValidationError

from sqlalchemy.orm import Session

from app.ai.insights.exceptions import (
    InsightsConfigurationError,
    InsightsError,
    InsightsPipelineError,
    InsightsValidationError,
)
from app.ai.insights.pipeline import InsightsPipeline, build_insights_pipeline
from app.ai.insights.repository import InsightsRepository, build_insights_repository
from app.ai.insights.schemas import InsightsPipelineInput, InsightsPipelineResult


class InsightsService:
    def __init__(self, *, pipeline: InsightsPipeline) -> None:
        self._pipeline = pipeline

    def generate_insights(
        self,
        request: InsightsPipelineInput | dict[str, Any],
        db: Any | None = None,
    ) -> InsightsPipelineResult:
        try:
            return self._pipeline.generate_insights(request=request, db=db)
        except InsightsError:
            raise
        except ValidationError as exc:
            raise InsightsValidationError("Invalid insights request") from exc
        except Exception as exc:  # noqa: BLE001 - service boundary
            raise InsightsPipelineError("Failed to generate insights") from exc


    def get_insights(
        self,
        request: InsightsPipelineInput | dict[str, Any],
        db: Any | None = None,
    ) -> InsightsPipelineResult:
        return self.generate_insights(request=request, db=db)


def build_insights_service(
    *,
    db: Session | None = None,
    repository: InsightsRepository | None = None,
    pipeline: InsightsPipeline | None = None,
) -> InsightsService:
    if pipeline is None:
        if repository is None:
            if db is None:
                raise InsightsConfigurationError("A database session is required to build the insights service")
            repository = build_insights_repository(db)
        pipeline = build_insights_pipeline(repository=repository)

    return InsightsService(pipeline=pipeline)
