import 'dart:js' as js;

void playBase64Audio(String base64Audio, String mimeType) {
  try {
    final audioSrc = 'data:$mimeType;base64,$base64Audio';
    js.context.callMethod('eval', [
      'var audio = new Audio("$audioSrc"); audio.play();'
    ]);
  } catch (e) {
    print('[Aura-Voice] Web Audio playback failed: $e');
  }
}
