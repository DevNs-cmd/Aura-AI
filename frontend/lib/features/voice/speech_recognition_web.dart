import 'dart:js' as js;

typedef SpeechResultCallback = void Function(String text);
typedef SpeechErrorCallback = void Function(String error);
typedef SpeechEndCallback = void Function();

void startSpeechRecognition({
  required SpeechResultCallback onResult,
  required SpeechErrorCallback onError,
  required SpeechEndCallback onEnd,
}) {
  try {
    js.context['__aura_speech_result__'] = js.allowInterop(onResult);
    js.context['__aura_speech_error__'] = js.allowInterop(onError);
    js.context['__aura_speech_end__'] = js.allowInterop(onEnd);
    
    js.context.callMethod('eval', [
      '''
      if (!window.__aura_speech_init__) {
        window.__aura_speech_init__ = true;
        window.__aura_speech_start__ = function() {
          if (!('webkitSpeechRecognition' in window) && !('SpeechRecognition' in window)) {
            if (window.__aura_speech_error__) {
              window.__aura_speech_error__("Speech recognition not supported in this browser.");
            }
            return;
          }
          if (window.__aura_recognition__) {
            window.__aura_recognition__.stop();
          }
          var SpeechRecognition = window.SpeechRecognition || window.webkitSpeechRecognition;
          var rec = new SpeechRecognition();
          rec.continuous = false;
          rec.interimResults = false;
          rec.lang = 'en-US';
          
          rec.onresult = function(event) {
            if (event.results.length > 0) {
              var text = event.results[0][0].transcript;
              if (window.__aura_speech_result__) {
                window.__aura_speech_result__(text);
              }
            }
          };
          
          rec.onerror = function(event) {
            if (window.__aura_speech_error__) {
              window.__aura_speech_error__(event.error);
            }
          };
          
          rec.onend = function() {
            if (window.__aura_speech_end__) {
              window.__aura_speech_end__();
            }
          };
          
          window.__aura_recognition__ = rec;
          rec.start();
        };
        
        window.__aura_speech_stop__ = function() {
          if (window.__aura_recognition__) {
            window.__aura_recognition__.stop();
          }
        };
      }
      window.__aura_speech_start__();
      '''
    ]);
  } catch (e) {
    onError(e.toString());
  }
}

void stopSpeechRecognition() {
  try {
    js.context.callMethod('eval', [
      '''
      if (window.__aura_speech_stop__) {
        window.__aura_speech_stop__();
      }
      '''
    ]);
  } catch (e) {
    print('Failed to stop speech recognition: $e');
  }
}
