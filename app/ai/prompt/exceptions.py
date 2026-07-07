class PromptError(Exception):
    """Base exception for prompt construction failures."""


class PromptBuildError(PromptError):
    """Raised when prompt assembly fails."""


class PromptValidationError(PromptError):
    """Raised when prompt input validation fails."""
