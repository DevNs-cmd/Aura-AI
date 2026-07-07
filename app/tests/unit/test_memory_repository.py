from __future__ import annotations

from datetime import datetime, timedelta
from uuid import UUID, uuid4

import pytest
from sqlalchemy import create_engine
from sqlalchemy.orm import sessionmaker

from app.ai.memory.exceptions import MemoryNotFoundError
from app.ai.memory.repository import SQLAlchemyMemoryRepository
from app.ai.memory.schemas import MemoryCreate, MemoryUpdate
from app.db.database import Base
from app.models.user import User


@pytest.fixture()
def session():
    engine = create_engine("sqlite:///:memory:")
    Base.metadata.create_all(bind=engine)
    SessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=engine)
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()
        Base.metadata.drop_all(bind=engine)
        engine.dispose()


def test_repository_crud_roundtrip(session):
    repo = SQLAlchemyMemoryRepository(db=session)
    user_id = uuid4()

    created = repo.create(
        MemoryCreate(user_id=user_id, key="favorite_food", value="biryani", source="chat")
    )

    assert created.id is not None
    assert created.user_id == user_id
    assert created.key == "favorite_food"

    fetched = repo.get_by_id(created.id)
    assert fetched is not None
    assert fetched.value == "biryani"

    updated = repo.update(created.id, MemoryUpdate(value="paneer biryani"))
    assert updated.value == "paneer biryani"

    listed = repo.list_by_user(user_id)
    assert [item.id for item in listed] == [created.id]

    repo.delete(created.id)
    assert repo.get_by_id(created.id) is None


def test_repository_list_orders_by_recent_update(session):
    repo = SQLAlchemyMemoryRepository(db=session)
    user_id = uuid4()

    first = repo.create(MemoryCreate(user_id=user_id, key="one", value="alpha", source="chat"))
    second = repo.create(MemoryCreate(user_id=user_id, key="two", value="beta", source="chat"))

    first.updated_at = datetime.utcnow() + timedelta(minutes=5)
    session.commit()

    listed = repo.list_by_user(user_id)
    assert [item.id for item in listed][:2] == [first.id, second.id]


def test_repository_raises_on_missing_record(session):
    repo = SQLAlchemyMemoryRepository(db=session)

    with pytest.raises(MemoryNotFoundError):
        repo.update(UUID("00000000-0000-0000-0000-000000000001"), MemoryUpdate(value="x"))

    with pytest.raises(MemoryNotFoundError):
        repo.delete(UUID("00000000-0000-0000-0000-000000000001"))
