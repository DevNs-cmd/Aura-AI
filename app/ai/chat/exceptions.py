class ChatError(Exception):
    """Base error for the chat orchestration domain."""


class ChatValidationError(ChatError):
    """Raised when chat input is invalid."""


class ChatPipelineError(ChatError):
    """Raised when orchestration fails."""


class ChatConfigurationError(ChatError):
    """Raised when chat dependencies are misconfigured."""
