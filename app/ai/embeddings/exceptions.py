class EmbeddingError(Exception):
    """Base error for the embedding domain."""


class EmbeddingValidationError(EmbeddingError):
    """Raised when user input is invalid."""


class EmbeddingProviderError(EmbeddingError):
    """Raised when a provider fails to generate embeddings."""


class EmbeddingRepositoryError(EmbeddingError):
    """Raised when metadata persistence fails."""


class VectorStoreError(EmbeddingError):
    """Raised when vector storage operations fail."""


class EmbeddingConfigurationError(EmbeddingError):
    """Raised when the embedding module is misconfigured."""
