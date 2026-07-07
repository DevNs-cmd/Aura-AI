from __future__ import annotations

from typing import Any


class PromptRepository:
    """Read-only prompt template source."""

    def __init__(
        self,
        db: Any | None = None,
        *,
        system_prompt: str | None = None,
        developer_prompt: str | None = None,
    ) -> None:
        self._db = db
        self._system_prompt = system_prompt or "You are Aura, a helpful and warm personal AI companion."
        self._developer_prompt = developer_prompt or (
            "Use the supplied context to answer accurately, stay grounded, and keep the response concise."
        )

    def get_templates(self) -> dict[str, str]:
        return {
            "system_prompt": self._system_prompt,
            "developer_prompt": self._developer_prompt,
        }

