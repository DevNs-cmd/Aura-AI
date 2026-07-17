import os
import uuid

from fastapi import APIRouter, Depends, UploadFile
from sqlalchemy.orm import Session

from app.api.deps import get_current_user
from app.ai.rag.document_indexing import chunk_text, extract_document_text, upsert_document_chunks_to_chroma
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
    )
    db.add(doc)
    db.commit()
    db.refresh(doc)

    # Index the document synchronously (MVP).
    indexing_status = "uploaded"
    try:
        extracted_text = extract_document_text(file_path=file_path, file_type=doc.file_type)
        chunks = chunk_text(extracted_text)

        upsert_document_chunks_to_chroma(
            user_id=user.id,
            document_id=doc.id,
            file_name=doc.filename,
            chunks=chunks,
        )
        indexing_status = "indexed"
    except Exception:
        indexing_status = "failed"
        raise

    return {
        "id": str(doc.id),
        "filename": doc.filename,
        "file_type": doc.file_type,
        "size_bytes": doc.size_bytes,
        "status": indexing_status,
    }


@router.get("")
def list_documents(db: Session = Depends(get_db), user: User = Depends(get_current_user)):
    docs = db.query(Document).filter(Document.user_id == user.id).all()
    return [
        {
            "id": str(d.id),
            "filename": d.filename,
            "file_type": d.file_type,
            "size_bytes": d.size_bytes,
            "status": "indexed",
        }
        for d in docs
    ]
