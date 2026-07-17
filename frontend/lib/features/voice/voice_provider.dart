import 'dart:async';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/network/api_client.dart';
import '../../core/network/api_config.dart';
import 'audio_player_stub.dart' if (dart.library.js) 'audio_player_web.dart';
import 'speech_recognition_stub.dart' if (dart.library.js) 'speech_recognition_web.dart';

enum VoiceStatus { listening, thinking, speaking }

class VoiceState {
  final VoiceStatus status;
  final bool isMuted;
  final bool isSpeakerOn;
  final String? userTranscript;
  final String? spokenText;
  final String? errorMessage;

  VoiceState({
    required this.status,
    this.isMuted = false,
    this.isSpeakerOn = true,
    this.userTranscript,
    this.spokenText,
    this.errorMessage,
  });

  VoiceState copyWith({
    VoiceStatus? status,
    bool? isMuted,
    bool? isSpeakerOn,
    String? userTranscript,
    String? spokenText,
    String? errorMessage,
  }) {
    return VoiceState(
      status: status ?? this.status,
      isMuted: isMuted ?? this.isMuted,
      isSpeakerOn: isSpeakerOn ?? this.isSpeakerOn,
      userTranscript: userTranscript ?? this.userTranscript,
      spokenText: spokenText ?? this.spokenText,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

class VoiceNotifier extends StateNotifier<VoiceState> {
  Timer? _speechTimer;

  VoiceNotifier() : super(VoiceState(status: VoiceStatus.thinking)) {
    _loadGreeting();
  }

  Future<void> _loadGreeting() async {
    state = state.copyWith(
      status: VoiceStatus.thinking,
      spokenText: null,
      userTranscript: null,
      errorMessage: null,
    );

    try {
      final dio = ApiClient().dio;
      final response = await dio.post<dynamic>(
        '/chat',
        data: {'message': 'Greet me shortly in 1 sentence as my Aura AI companion.'},
      );
      final data = response.data;
      final reply = data['reply']?.toString() ?? "Hello! I am Aura, your personal guide. How can I help you today?";
      
      _speak(reply);
    } catch (e) {
      _speak("Hello! I am Aura, your personal companion. How can I support you today?");
    }
  }

  void _speak(String text) async {
    _speechTimer?.cancel();
    state = state.copyWith(
      status: VoiceStatus.speaking,
      spokenText: text,
    );

    // Call voice synthesize endpoint on backend to fetch real audio bytes
    try {
      final dio = Dio();
      final response = await dio.post<dynamic>(
        '${ApiConfig.aiBaseUrl}/voice/synthesize',
        data: {'text': text},
      );
      if (response.data != null && response.data['audio'] != null) {
        final base64Audio = response.data['audio'].toString();
        final mimeType = response.data['mime_type']?.toString() ?? 'audio/mp3';
        
        // Stop recognition while AI is playing audio
        stopSpeechRecognition();
        _speechTimer?.cancel();
        
        playBase64Audio(base64Audio, mimeType, () {
          if (!mounted) return;
          startListening();
        });
        return;
      }
    } catch (e) {
      print('[Aura-Voice] TTS Synthesis failed (using text fallback): $e');
    }

    // Fallback: Simulate speaking duration if synthesis failed
    final durationMs = (text.length * 60).clamp(2500, 9000);
    _speechTimer = Timer(Duration(milliseconds: durationMs), () {
      if (!mounted) return;
      startListening();
    });
  }

  void startListening() {
    if (state.isMuted) return;
    
    state = state.copyWith(
      status: VoiceStatus.listening,
      spokenText: null,
      errorMessage: null,
    );
    
    startSpeechRecognition(
      onResult: (text) {
        if (text.trim().isNotEmpty && mounted) {
          sendPrompt(text);
        }
      },
      onError: (error) {
        print('[Aura-Voice] Speech recognition error: $error');
      },
      onEnd: () {
        // ended naturally
      },
    );
  }

  Future<void> sendPrompt(String prompt) async {
    stopSpeechRecognition();
    _speechTimer?.cancel();
    state = state.copyWith(
      status: VoiceStatus.thinking,
      userTranscript: prompt,
      spokenText: null,
      errorMessage: null,
    );

    try {
      final dio = ApiClient().dio;
      final response = await dio.post<dynamic>(
        '/chat',
        data: {'message': prompt},
      );

      final data = response.data;
      final reply = data['reply']?.toString();
      if (reply == null || reply.isEmpty) {
        throw const FormatException('Empty response from AI.');
      }

      if (!mounted) return;
      _speak(reply);
    } catch (e) {
      if (!mounted) return;
      state = state.copyWith(
        status: VoiceStatus.speaking,
        spokenText: "I'm having trouble connecting to my cognitive services right now. Error: $e",
      );
    }
  }

  void toggleMute() {
    final newMuted = !state.isMuted;
    state = state.copyWith(isMuted: newMuted);
    if (newMuted) {
      stopSpeechRecognition();
      state = state.copyWith(status: VoiceStatus.listening);
    } else {
      if (state.status == VoiceStatus.listening) {
        startListening();
      }
    }
  }

  void toggleSpeaker() {
    state = state.copyWith(isSpeakerOn: !state.isSpeakerOn);
  }

  @override
  void dispose() {
    _speechTimer?.cancel();
    stopSpeechRecognition();
    super.dispose();
  }
}

final voiceProvider = StateNotifierProvider<VoiceNotifier, VoiceState>((ref) {
  return VoiceNotifier();
});
