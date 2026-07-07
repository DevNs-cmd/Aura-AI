from __future__ import annotations

import uuid
from datetime import datetime

from sqlalchemy import Column, DateTime, String

from app.db.database import Base


class EmbeddingRecord(Base):
    __tablename__ = "embeddings"

    id = Column(String(36), primary_key=True, default=lambda: str(uuid.uuid4()))
    source_type = Column(String(64), nullable=True, index=True)
    source_id = Column(String(64), nullable=True, index=True)
    content_hash = Column(String(64), nullable=False, index=True)
    provider = Column(String(64), nullable=False)
    model_name = Column(String(128), nullable=False)
    created_at = Column(DateTime, default=datetime.utcnow, nullable=False)
