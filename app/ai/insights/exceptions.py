class InsightsError(Exception):
    """Base error for the insights domain."""


class InsightsValidationError(InsightsError):
    """Raised when insights input is invalid."""


class InsightsRepositoryError(InsightsError):
    """Raised when insights data access fails."""


class InsightsPipelineError(InsightsError):
    """Raised when insights orchestration fails."""


class InsightsConfigurationError(InsightsError):
    """Raised when insights dependencies are misconfigured."""
