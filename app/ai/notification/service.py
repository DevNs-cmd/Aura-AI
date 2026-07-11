from __future__ import annotations

from __future__ import annotations

from app.ai.notification.pipeline import NotificationPipeline
from app.ai.notification.repository import NotificationRepository
from app.ai.notification.schemas import NotificationRequest, NotificationResponse


class NotificationService:
    """Thin wrapper around NotificationPipeline."""

    def __init__(self, *, pipeline: NotificationPipeline):
        self.pipeline = pipeline

    def generate(self, request: NotificationRequest) -> NotificationResponse:
        return self.pipeline.run(request=request)


def build_notification_service(*, pipeline: NotificationPipeline | None = None) -> NotificationService:
    if pipeline is not None:
        return NotificationService(pipeline=pipeline)

    # Build a request-driven default service.
    class _DefaultNotificationService(NotificationService):
        def __init__(self):
            super().__init__(pipeline=NotificationPipeline(repository=NotificationRepository(request=NotificationRequest(now=NotificationRequest.model_validate({"now": "2000-01-01T00:00:00"}).now))))

        def generate(self, request: NotificationRequest) -> NotificationResponse:
            repo = NotificationRepository(request=request)
            pipeline = NotificationPipeline(repository=repo)
            return pipeline.run(request=request)

    return _DefaultNotificationService()


