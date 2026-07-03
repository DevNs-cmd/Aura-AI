import os
import uuid

from fastapi import APIRouter, Depends, UploadFile
from sqlalchemy.orm import Session

from app.api.deps import get_current_user
from app.db.database import get_db
from app.models.document import Document
from app.models.user import User

router = APIRouter(prefix="/documents", tags=["Documents"])

UPLOAD_DIR = "uploads"
os.makedirs(UPLOAD_DIR, exist_ok=True)


@router.post("/upload")
async def upload_document(
    file: UploadFile,
    db: Session = Depends(get_db),
    user: User = Depends(get_current_user),
):
    # G4 File Storage (local for MVP, swap for S3 later)
    ext = os.path.splitext(file.filename)[1]
    stored_name = f"{uuid.uuid4()}{ext}"
    file_path = os.path.join(UPLOAD_DIR, stored_name)

    contents = await file.read()
    with open(file_path, "wb") as f:
        f.write(contents)

    doc = Document(
        user_id=user.id,
        filename=file.filename,
        file_path=file_path,
        file_type=file.content_type,
        size_bytes=len(contents),
        status="uploaded",
    )
    db.add(doc)
    db.commit()
    db.refresh(doc)

    # TODO: trigger RAG pipeline (F1-F5) as a background task to chunk + embed

    return {"id": doc.id, "filename": doc.filename, "status": doc.status}


@router.get("")
def list_documents(db: Session = Depends(get_db), user: User = Depends(get_current_user)):
    return db.query(Document).filter(Document.user_id == user.id).all()
