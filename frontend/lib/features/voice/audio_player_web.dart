import 'dart:js' as js;

typedef AudioEndCallback = void Function();

void playBase64Audio(String base64Audio, String mimeType, AudioEndCallback onEnded) {
  try {
    js.context['__aura_audio_ended__'] = js.allowInterop(onEnded);
    final audioSrc = 'data:$mimeType;base64,$base64Audio';
    
    js.context.callMethod('eval', [
      '''
      if (window.__aura_audio__) {
        try {
          window.__aura_audio__.pause();
        } catch(e) {}
      }
      var audio = new Audio("$audioSrc");
      window.__aura_audio__ = audio;
      audio.onended = function() {
        if (window.__aura_audio_ended__) {
          window.__aura_audio_ended__();
        }
      };
      audio.onerror = function() {
        if (window.__aura_audio_ended__) {
          window.__aura_audio_ended__();
        }
      };
      audio.play();
      '''
    ]);
  } catch (e) {
    print('[Aura-Voice] Web Audio playback failed: $e');
    // Call callback fallback immediately so we don't get stuck
    onEnded();
  }
}
