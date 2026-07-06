from __future__ import annotations

from sqlalchemy.orm import Session


class ContextRepository:
    """Read-only database access helpers used by context assembly."""

    def __init__(self, db: Session | None = None) -> None:
        self._db = db

    @property
    def db(self) -> Session | None:
        return self._db
