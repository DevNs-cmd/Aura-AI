import uuid
from datetime import datetime

from sqlalchemy import Column, String, DateTime, ForeignKey, Integer
from sqlalchemy.dialects.postgresql import UUID

from app.db.database import Base


class Document(Base):
    __tablename__ = "documents"

    id = Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    user_id = Column(UUID(as_uuid=True), ForeignKey("users.id"), nullable=False)

    # DB column is "file_name"
    filename = Column("file_name", String, nullable=False)

    # DB column is "file_url" (stores local file path for MVP)
    file_path = Column("file_url", String, nullable=True)

    file_type = Column(String, nullable=True)

    # DB column is "file_size"
    size_bytes = Column("file_size", Integer, nullable=True)

    created_at = Column(DateTime, default=datetime.utcnow)

    # "status" does not exist in the current DB schema.
    # It is handled as a Python-only attribute so the endpoint code
    # can still reference doc.status without touching the DB.
    @property
    def status(self):
        return getattr(self, "_status", "uploaded")

    @status.setter
    def status(self, value):
        self._status = value
