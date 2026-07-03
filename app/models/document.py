import uuid
from datetime import datetime

from sqlalchemy import Column, String, DateTime, ForeignKey, Integer
from sqlalchemy.dialects.postgresql import UUID

from app.db.database import Base


class Document(Base):
    __tablename__ = "documents"

    id = Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    user_id = Column(UUID(as_uuid=True), ForeignKey("users.id"), nullable=False)
    filename = Column(String, nullable=False)
    file_path = Column(String, nullable=False)   # G4 File Storage path/URL
    file_type = Column(String, nullable=True)
    size_bytes = Column(Integer, nullable=True)
    status = Column(String, default="uploaded")  # uploaded | processing | indexed | failed
    created_at = Column(DateTime, default=datetime.utcnow)
