class LLMError(Exception):
    """Base error for the LLM domain."""


class LLMValidationError(LLMError):
    """Raised when LLM input is invalid."""


class LLMProviderError(LLMError):
    """Raised when an LLM provider fails."""


class LLMTransientError(LLMProviderError):
    """Raised when a provider failure is retryable."""


class LLMResponseError(LLMError):
    """Raised when a provider response cannot be normalized."""


class LLMRetryError(LLMError):
    """Raised when retry attempts are exhausted."""


class LLMConfigurationError(LLMError):
    """Raised when LLM dependencies are misconfigured."""
