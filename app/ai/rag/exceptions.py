class RagError(Exception):
    """Base error for the RAG domain."""


class RagValidationError(RagError):
    """Raised when RAG input is invalid."""


class RagRetrievalError(RagError):
    """Raised when retrieval fails."""


class RagRepositoryError(RagError):
    """Raised when document metadata access fails."""


class RagConfigurationError(RagError):
    """Raised when RAG dependencies are misconfigured."""
