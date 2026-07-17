import os
import uuid
import logging

from fastapi import APIRouter, Depends, UploadFile, BackgroundTasks
from sqlalchemy.orm import Session

from app.api.deps import get_current_user
from app.ai.rag.document_indexing import chunk_text, extract_document_text, upsert_document_chunks_to_chroma
from app.db.database import get_db
from app.models.document import Document
from app.models.user import User

logger = logging.getLogger(__name__)

router = APIRouter(prefix="/documents", tags=["Documents"])

UPLOAD_DIR = "uploads"
os.makedirs(UPLOAD_DIR, exist_ok=True)


def run_indexing(file_path: str, doc_id: uuid.UUID, user_id: uuid.UUID, filename: str, content_type: str):
    try:
        logger.info(f"Starting background indexing for document {doc_id}")
        extracted_text = extract_document_text(file_path=file_path, file_type=content_type)
        chunks = chunk_text(extracted_text)

        upsert_document_chunks_to_chroma(
            user_id=user_id,
            document_id=doc_id,
            file_name=filename,
            chunks=chunks,
        )
        logger.info(f"Successfully completed background indexing for document {doc_id}")
    except Exception as e:
        logger.error(f"Failed background indexing for document {doc_id}: {e}", exc_info=True)


@router.post("/upload")
async def upload_document(
    file: UploadFile,
    background_tasks: BackgroundTasks,
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

    background_tasks.add_task(
        run_indexing,
        file_path=file_path,
        doc_id=doc.id,
        user_id=user.id,
        filename=doc.filename,
        content_type=doc.file_type,
    )

    doc.status = "indexing"

    return {
        "id": str(doc.id),
        "filename": doc.filename,
        "file_type": doc.file_type,
        "size_bytes": doc.size_bytes,
        "status": doc.status,
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
