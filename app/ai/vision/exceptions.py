class VisionError(Exception):
    """Base error for the vision domain."""


class VisionValidationError(VisionError):
    """Raised when a request or payload fails validation."""


class VisionConfigurationError(VisionError):
    """Raised when the vision stack is misconfigured."""


class VisionPipelineError(VisionError):
    """Raised when orchestration or normalization fails."""


class VisionProviderError(VisionError):
    """Raised when the underlying vision provider fails."""


class VisionRepositoryError(VisionError):
    """Raised when the repository cannot invoke the provider."""
