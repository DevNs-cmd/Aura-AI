from __future__ import annotations

import pytest

from app.ai.embeddings.exceptions import EmbeddingConfigurationError, EmbeddingProviderError, EmbeddingValidationError
from app.ai.embeddings.provider import DeterministicEmbeddingProvider, build_embedding_provider
from app.ai.embeddings.service import EmbeddingService


class FakeProvider:
    provider_name = "fake"
    model_name = "fake-model"
    dimension = 3

    def __init__(self, *, fail_on_batch: bool = False):
        self.fail_on_batch = fail_on_batch
        self.last_single_text = None
        self.last_batch_texts = None

    def generate_embedding(self, text: str) -> list[float]:
        self.last_single_text = text
        return [0.1, 0.2, 0.3]

    def generate_batch_embeddings(self, texts):
        self.last_batch_texts = list(texts)
        if self.fail_on_batch:
            raise RuntimeError("boom")
        return [[0.1, 0.2, 0.3] for _ in self.last_batch_texts]


def test_generate_embedding_normalizes_input_and_delegates():
    provider = FakeProvider()
    service = EmbeddingService(provider=provider)

    vector = service.generate_embedding("  Hello   world  ")

    assert vector == [0.1, 0.2, 0.3]
    assert provider.last_single_text == "Hello world"


def test_generate_batch_embeddings_normalizes_input_and_preserves_order():
    provider = FakeProvider()
    service = EmbeddingService(provider=provider)

    vectors = service.generate_batch_embeddings(["  First  text ", "Second   text"])

    assert vectors == [[0.1, 0.2, 0.3], [0.1, 0.2, 0.3]]
    assert provider.last_batch_texts == ["First text", "Second text"]


def test_generate_embedding_rejects_blank_text():
    service = EmbeddingService(provider=FakeProvider())

    with pytest.raises(EmbeddingValidationError):
        service.generate_embedding("   ")


def test_generate_batch_embeddings_rejects_empty_sequence():
    service = EmbeddingService(provider=FakeProvider())

    with pytest.raises(EmbeddingValidationError):
        service.generate_batch_embeddings([])


def test_generate_batch_embeddings_wraps_unexpected_errors():
    service = EmbeddingService(provider=FakeProvider(fail_on_batch=True))

    with pytest.raises(EmbeddingProviderError):
        service.generate_batch_embeddings(["hello"])


def test_deterministic_provider_is_stable():
    provider = DeterministicEmbeddingProvider(model_name="test-model", dimension=16)

    first = provider.generate_embedding("Hello world")
    second = provider.generate_embedding("Hello world")

    assert first == second
    assert len(first) == 16


def test_build_embedding_provider_rejects_deterministic_in_production(monkeypatch):
    monkeypatch.setattr("app.ai.embeddings.provider.settings.EMBEDDING_PROVIDER", "deterministic")

    with pytest.raises(EmbeddingConfigurationError):
        build_embedding_provider()
