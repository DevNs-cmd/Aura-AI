from __future__ import annotations

from uuid import UUID

from app.ai.embeddings.service import EmbeddingService
from app.ai.journal.exceptions import JournalConfigurationError, JournalPipelineError
from app.ai.journal.insights import JournalInsightExtractor, build_journal_insight_extractor
from app.ai.journal.reflection import JournalReflectionGenerator, build_journal_reflection_generator
from app.ai.journal.repository import JournalRepository
from app.ai.journal.schemas import (
    JournalArtifactUpdate,
    JournalEntryCreate,
    JournalEntryRead,
    JournalEntryUpdate,
    JournalMemorySeed,
    JournalPipelineResult,
)
from app.ai.journal.utils import build_entry_text
from app.ai.memory.schemas import MemoryCreate
from app.ai.memory.service import MemoryService
from app.ai.vectorstore import VectorStore


class JournalPipeline:
    def __init__(
        self,
        *,
        repository: JournalRepository,
        embedding_service: EmbeddingService,
        vector_store: VectorStore,
        memory_service: MemoryService,
        insight_extractor: JournalInsightExtractor | None = None,
        reflection_generator: JournalReflectionGenerator | None = None,
    ):
        self.repository = repository
        self.embedding_service = embedding_service
        self.vector_store = vector_store
        self.memory_service = memory_service
        self.insight_extractor = insight_extractor or build_journal_insight_extractor()
        self.reflection_generator = reflection_generator or build_journal_reflection_generator()

    @staticmethod
    def _entry_read(entry) -> JournalEntryRead:
        return JournalEntryRead.model_validate(entry, from_attributes=True)

    @staticmethod
    def _memory_payloads(user_id: UUID, insights_summary: str, keywords: list[str], mood: str) -> list[JournalMemorySeed]:
        focus = keywords[0] if keywords else mood
        return [
            JournalMemorySeed(user_id=user_id, key="journal_mood", value=mood, source="journal"),
            JournalMemorySeed(user_id=user_id, key="journal_summary", value=insights_summary, source="journal"),
            JournalMemorySeed(user_id=user_id, key="journal_focus", value=focus, source="journal"),
        ]

    def _run(self, entry, *, user_id: UUID) -> JournalPipelineResult:
        embedding_id = str(entry.id)
        vector = self.embedding_service.embed_text(build_entry_text(entry.title, entry.content))
        self.vector_store.upsert(
            embedding_id=embedding_id,
            vector=vector,
            metadata={
                "source_type": "journal",
                "source_id": embedding_id,
                "user_id": str(user_id),
                "title": entry.title,
            },
        )

        try:
            insights = self.insight_extractor.extract(title=entry.title, content=entry.content)
            reflection = self.reflection_generator.generate(title=entry.title, content=entry.content, insights=insights)
            artifacts = JournalArtifactUpdate(
                summary=insights.summary,
                mood=insights.mood,
                keywords=list(insights.keywords),
                reflection=reflection.reflection,
                follow_up_suggestions=list(reflection.follow_up_suggestions),
                embedding_id=embedding_id,
            )
            memory_payloads = self._memory_payloads(
                user_id,
                insights.summary,
                list(insights.keywords),
                insights.mood,
            )
            self.memory_service.upsert_memories(
                [
                    MemoryCreate(
                        user_id=payload.user_id,
                        key=payload.key,
                        value=payload.value,
                        source=payload.source,
                    )
                    for payload in memory_payloads
                ]
            )
            entry = self.repository.update_artifacts(entry.id, artifacts)
            return JournalPipelineResult(
                entry=self._entry_read(entry),
                insights=insights,
                reflection=reflection,
                artifacts=artifacts,
                memory_payloads=memory_payloads,
                embedding_id=embedding_id,
                vector=[float(value) for value in vector],
            )
        except Exception as exc:
            try:
                self.vector_store.delete(embedding_id)
            except Exception:
                pass
            raise JournalPipelineError("Failed to process journal entry") from exc

    def create_entry(self, *, user_id: UUID, payload: JournalEntryCreate) -> JournalPipelineResult:
        entry = self.repository.create(user_id=user_id, payload=payload)
        return self._run(entry, user_id=user_id)

    def update_entry(self, *, user_id: UUID, entry_id: UUID, payload: JournalEntryUpdate) -> JournalPipelineResult:
        entry = self.repository.update(entry_id, payload)
        return self._run(entry, user_id=user_id)


def build_journal_pipeline(
    *,
    repository: JournalRepository | None = None,
    embedding_service: EmbeddingService | None = None,
    vector_store: VectorStore | None = None,
    memory_service: MemoryService | None = None,
    insight_extractor: JournalInsightExtractor | None = None,
    reflection_generator: JournalReflectionGenerator | None = None,
) -> JournalPipeline:
    if repository is None:
        raise JournalConfigurationError("A journal repository is required to build the journal pipeline")
    if embedding_service is None:
        raise JournalConfigurationError("An embedding service is required to build the journal pipeline")
    if vector_store is None:
        raise JournalConfigurationError("A vector store is required to build the journal pipeline")
    if memory_service is None:
        raise JournalConfigurationError("A memory service is required to build the journal pipeline")

    return JournalPipeline(
        repository=repository,
        embedding_service=embedding_service,
        vector_store=vector_store,
        memory_service=memory_service,
        insight_extractor=insight_extractor,
        reflection_generator=reflection_generator,
    )
