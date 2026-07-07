class ContextError(Exception):
    """Base exception for context orchestration failures."""


class ContextDependencyError(ContextError):
    """Raised when an upstream AI dependency cannot be loaded or called."""


class ContextPipelineError(ContextError):
    """Raised when context assembly fails."""
