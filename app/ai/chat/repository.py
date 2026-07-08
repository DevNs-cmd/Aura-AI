from __future__ import annotations

from typing import Any


class ChatRepository:
    """Read-only holder for downstream DB access passed through chat orchestration."""

    def __init__(self, db: Any | None = None) -> None:
        self._db = db

    @property
    def db(self) -> Any | None:
        return self._db
