from __future__ import annotations

import uuid

from fastapi import APIRouter, Depends

from app.ai.journal.schemas import JournalEntryCreate, JournalEntryRead, JournalEntryUpdate
from app.ai.journal.service import JournalService
from app.api.deps import get_current_user, get_journal_service
from app.models.user import User

router = APIRouter(prefix="/journal", tags=["Journal"])


@router.post("/entries", response_model=JournalEntryRead)
def create_entry(
    payload: JournalEntryCreate,
    service: JournalService = Depends(get_journal_service),
    user: User = Depends(get_current_user),
):
    return service.create_entry(user_id=user.id, payload=payload)


@router.get("/entries", response_model=list[JournalEntryRead])
def list_entries(
    service: JournalService = Depends(get_journal_service),
    user: User = Depends(get_current_user),
):
    return service.list_entries(user_id=user.id)


@router.get("/entries/{entry_id}", response_model=JournalEntryRead)
def get_entry(
    entry_id: uuid.UUID,
    service: JournalService = Depends(get_journal_service),
    user: User = Depends(get_current_user),
):
    return service.get_entry(user_id=user.id, entry_id=entry_id)


@router.patch("/entries/{entry_id}", response_model=JournalEntryRead)
def update_entry(
    entry_id: uuid.UUID,
    payload: JournalEntryUpdate,
    service: JournalService = Depends(get_journal_service),
    user: User = Depends(get_current_user),
):
    return service.update_entry(user_id=user.id, entry_id=entry_id, payload=payload)


@router.delete("/entries/{entry_id}", response_model=JournalEntryRead)
def delete_entry(
    entry_id: uuid.UUID,
    service: JournalService = Depends(get_journal_service),
    user: User = Depends(get_current_user),
):
    return service.delete_entry(user_id=user.id, entry_id=entry_id)
