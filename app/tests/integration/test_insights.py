from __future__ import annotations

from datetime import datetime, timedelta
from uuid import uuid4

import pytest
from sqlalchemy import create_engine
from sqlalchemy.orm import sessionmaker

from app.ai.insights.pipeline import build_insights_pipeline
from app.ai.insights.repository import build_insights_repository
from app.ai.insights.service import build_insights_service
from app.db.database import Base
from app.models.chat import ChatSession, Message
from app.models.document import Document
from app.models.journal import JournalEntry
from app.models.memory import Memory
from app.models.user import User
from app.ai.insights.schemas import InsightsPipelineInput


def make_session():
    engine = create_engine("sqlite:///:memory:")
    Base.metadata.create_all(bind=engine)
    SessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=engine)
    return engine, SessionLocal()


@pytest.mark.integration
def test_insights_end_to_end_with_sqlite_stack():
    engine, session = make_session()
    try:
        user = User(id=uuid4(), email="x@example.com", hashed_password="pw", full_name="u")

        session.add(user)
        session.commit()

        # Journal entries across week
        base = datetime(2024, 1, 1)  # Monday
        for i in range(4):
            session.add(
                JournalEntry(
                    user_id=user.id,
                    title=f"t{i}",
                    content=(
                        "I did complete tasks and felt focused"
                        if i % 2 == 0
                        else "I felt tired and stressed"
                    ),
                    created_at=base + timedelta(days=i),
                    updated_at=base + timedelta(days=i),
                )
            )

        chat = ChatSession(user_id=user.id, title="c")
        session.add(chat)
        session.commit()

        session.add(
            Message(
                session_id=chat.id,
                role="user",
                content="focused priority deep work accomplished",
                created_at=base + timedelta(days=5),
            )
        )

        session.add(
            Document(
                user_id=user.id,
                filename="doc",
                file_path="/tmp/doc",
                file_type="pdf",
                status="indexed",
                created_at=base + timedelta(days=2),
            )
        )

        session.add(
            Memory(user_id=user.id, key="k", value="v", source="manual", created_at=base + timedelta(days=6))
        )

        session.commit()

        repo = build_insights_repository(db=session)
        pipeline = build_insights_pipeline(repository=repo)
        service = build_insights_service(db=None, repository=repo, pipeline=pipeline)

        request = InsightsPipelineInput(user_id=user.id)
        result = service.get_insights(request, db=None)

        assert result.journal_badge in {
            "Productive",
            "Focused",
            "Happy",
            "Motivated",
            "Reflective",
            "Calm",
            "Optimistic",
            "Energetic",
            "Balanced",
            "Thoughtful",
            "Creative",
            "Stressed",
            "Anxious",
            "Overwhelmed",
            "Tired",
        }
        assert " " not in result.journal_badge

        assert 1 <= len([s for s in result.journal_insight.replace("!", ".").replace("?", ".").split(".") if s.strip()]) <= 3

        ui = result.usage_insights
        assert ui.daily_activity.Mon >= 0
        assert ui.usage_trend.trend in {"Improving", "Stable", "Declining", "Mixed"}
        assert len(ui.usage_trend.chart_values) == 7
        assert isinstance(ui.weekly_percentage_change, float)
        assert 0 <= ui.weekly_productivity.score <= 100

    finally:
        session.close()
        Base.metadata.drop_all(bind=engine)
        engine.dispose()

