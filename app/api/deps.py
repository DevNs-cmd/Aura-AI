from functools import lru_cache
from typing import Any

from fastapi import Depends, HTTPException, status
from fastapi.security import OAuth2PasswordBearer
from sqlalchemy.orm import Session

from app.ai.chat.pipeline import ChatPipeline, build_chat_pipeline
from app.ai.chat.service import ChatService, build_chat_service
from app.ai.context.pipeline import ContextPipeline
from app.ai.context.schemas import JournalContext, MemoryContext, RetrievalContext
from app.ai.context.service import ContextService
from app.ai.embeddings.service import EmbeddingService, build_embedding_service
from app.ai.journal.cache import JournalCache, build_journal_cache
from app.ai.journal.service import JournalService, build_journal_service
from app.ai.llm.service import LLMService, build_llm_service
from app.ai.memory.cache import MemoryCache, build_memory_cache
from app.ai.memory.repository import build_memory_repository
from app.ai.memory.service import MemoryService, build_memory_service
from app.ai.rag.repository import build_document_repository
from app.ai.rag.service import RagService, build_rag_service
from app.ai.prompt.pipeline import PromptPipeline
from app.ai.prompt.service import PromptService
from app.ai.vectorstore import VectorStore, build_vector_store
from app.core.security import decode_token
from app.db.database import get_db
from app.models.user import User

oauth2_scheme = OAuth2PasswordBearer(tokenUrl="/api/v1/auth/login")


def get_current_user(token: str = Depends(oauth2_scheme), db: Session = Depends(get_db)) -> User:
    credentials_exception = HTTPException(
        status_code=status.HTTP_401_UNAUTHORIZED,
        detail="Could not validate credentials",
        headers={"WWW-Authenticate": "Bearer"},
    )

    payload = decode_token(token)
    if payload is None or payload.get("type") != "access":
        raise credentials_exception

    user_id = payload.get("sub")
    if user_id is None:
        raise credentials_exception

    user = db.query(User).filter(User.id == user_id).first()
    if user is None or not user.is_active:
        raise credentials_exception

    return user


def get_journal_service(db: Session = Depends(get_db)) -> JournalService:
    return build_journal_service(db=db)


class _MemoryContextAdapter:
    def __init__(self, service: MemoryService) -> None:
        self._service = service

    def get_context(
        self,
        request: Any,
        db: Any | None = None,
        query: str | None = None,
        limit: int | None = None,
        top_k: int | None = None,
    ) -> MemoryContext:
        user_id = getattr(request, "user_id", None)
        query_text = query or getattr(request, "query", "")
        memory_limit = limit if limit is not None else top_k if top_k is not None else getattr(request, "memory_limit", 5)

        if user_id is None or not query_text:
            return MemoryContext()

        memories = self._service.retrieve_memories(query_text, user_id=user_id, top_k=memory_limit)
        return MemoryContext(memories=[item.memory.model_dump(mode="json") for item in memories])


class _JournalContextAdapter:
    def __init__(self, service: JournalService) -> None:
        self._service = service

    def get_context(
        self,
        request: Any,
        db: Any | None = None,
        query: str | None = None,
        limit: int | None = None,
        top_k: int | None = None,
    ) -> JournalContext:
        user_id = getattr(request, "user_id", None)
        journal_limit = limit if limit is not None else top_k if top_k is not None else getattr(request, "journal_limit", 5)

        if user_id is None:
            return JournalContext()

        entries = self._service.list_entries(user_id=user_id, limit=journal_limit)
        return JournalContext(entries=[entry.model_dump(mode="json") for entry in entries])


class _RagContextAdapter:
    def __init__(self, service: RagService) -> None:
        self._service = service

    def get_context(
        self,
        request: Any,
        db: Any | None = None,
        query: str | None = None,
        limit: int | None = None,
        top_k: int | None = None,
    ) -> RetrievalContext:
        query_text = query or getattr(request, "query", "")
        retrieval_limit = limit if limit is not None else top_k if top_k is not None else getattr(request, "retrieval_limit", 5)

        if not query_text:
            return RetrievalContext()

        documents = self._service.retrieve_chunks(query_text, top_k=retrieval_limit)
        return RetrievalContext(
            query=query_text,
            documents=[chunk.model_dump(mode="json") for chunk in documents],
        )


@lru_cache(maxsize=1)
def _get_embedding_service() -> EmbeddingService:
    return build_embedding_service()


@lru_cache(maxsize=1)
def _get_vector_store() -> VectorStore:
    return build_vector_store()


@lru_cache(maxsize=1)
def _get_memory_cache() -> MemoryCache:
    return build_memory_cache()


@lru_cache(maxsize=1)
def _get_journal_cache() -> JournalCache:
    return build_journal_cache()


@lru_cache(maxsize=1)
def _get_llm_service() -> LLMService:
    return build_llm_service()


def get_ai_chat_service(db: Session = Depends(get_db)) -> ChatService:
    embedding_service = _get_embedding_service()
    vector_store = _get_vector_store()

    memory_service = build_memory_service(
        repository=build_memory_repository(db),
        cache=_get_memory_cache(),
        embedding_service=embedding_service,
        vector_store=vector_store,
    )
    rag_service = build_rag_service(
        db=db,
        embedding_service=embedding_service,
        vector_store=vector_store,
        document_repository=build_document_repository(db),
    )
    journal_service = build_journal_service(
        db=db,
        cache=_get_journal_cache(),
        embedding_service=embedding_service,
        vector_store=vector_store,
        memory_service=memory_service,
    )
    context_service = ContextService(
        pipeline=ContextPipeline(
            memory_service=_MemoryContextAdapter(memory_service),
            journal_service=_JournalContextAdapter(journal_service),
            rag_service=_RagContextAdapter(rag_service),
        )
    )
    prompt_service = PromptService(pipeline=PromptPipeline(context_service=context_service))
    chat_pipeline = build_chat_pipeline(
        context_service=context_service,
        prompt_service=prompt_service,
        llm_service=_get_llm_service(),
        memory_service=memory_service,
        journal_service=journal_service,
    )
    return build_chat_service(pipeline=chat_pipeline)


def get_voice_service() -> Any:
    from app.ai.voice.service import build_voice_service
    from app.ai.voice.providers import OpenRouterSTTProvider, GoogleTranslateTTSProvider
    return build_voice_service(
        stt_provider=OpenRouterSTTProvider(),
        tts_provider=GoogleTranslateTTSProvider()
    )

