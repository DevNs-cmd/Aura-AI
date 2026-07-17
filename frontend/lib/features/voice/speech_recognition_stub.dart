typedef SpeechResultCallback = void Function(String text);
typedef SpeechErrorCallback = void Function(String error);
typedef SpeechEndCallback = void Function();

void startSpeechRecognition({
  required SpeechResultCallback onResult,
  required SpeechErrorCallback onError,
  required SpeechEndCallback onEnd,
}) {
  // Stub implementation
}

void stopSpeechRecognition() {
  // Stub implementation
}
