class JournalError(Exception):
    """Base error for the journal domain."""


class JournalValidationError(JournalError):
    """Raised when journal input is invalid."""


class JournalNotFoundError(JournalError):
    """Raised when a requested journal entry does not exist."""


class JournalRepositoryError(JournalError):
    """Raised when journal persistence fails."""


class JournalCacheError(JournalError):
    """Raised when journal cache operations fail."""


class JournalPipelineError(JournalError):
    """Raised when journal orchestration fails."""


class JournalConfigurationError(JournalError):
    """Raised when journal dependencies are misconfigured."""
