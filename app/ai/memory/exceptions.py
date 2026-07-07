class MemoryError(Exception):
    """Base error for the memory domain."""


class MemoryValidationError(MemoryError):
    """Raised when memory input is invalid."""


class MemoryRepositoryError(MemoryError):
    """Raised when memory persistence fails."""


class MemoryNotFoundError(MemoryRepositoryError):
    """Raised when a requested memory record does not exist."""


class MemoryCacheError(MemoryError):
    """Raised when cache operations fail."""


class MemoryRetrievalError(MemoryError):
    """Raised when memory retrieval fails."""


class MemoryRankingError(MemoryError):
    """Raised when memory ranking fails."""


class MemoryConfigurationError(MemoryError):
    """Raised when memory dependencies are misconfigured."""
