class VoiceError(Exception):
    """Base error for the voice orchestration domain."""


class VoiceValidationError(VoiceError):
    """Raised when voice input payloads are invalid."""


class VoiceAudioValidationError(VoiceValidationError):
    """Raised when uploaded or synthesized audio fails validation."""


class VoicePipelineError(VoiceError):
    """Raised when voice orchestration fails."""


class VoiceProviderError(VoiceError):
    """Raised when a voice provider returns an unexpected payload."""


class VoiceRepositoryError(VoiceError):
    """Raised when the provider abstraction cannot be invoked."""


class VoiceConfigurationError(VoiceError):
    """Raised when voice dependencies are misconfigured."""
