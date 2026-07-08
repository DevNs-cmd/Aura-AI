import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';

enum VoiceStatus { listening, thinking, speaking }

class VoiceState {
  final VoiceStatus status;
  final bool isMuted;
  final bool isSpeakerOn;

  VoiceState({
    required this.status,
    this.isMuted = false,
    this.isSpeakerOn = true,
  });

  VoiceState copyWith({VoiceStatus? status, bool? isMuted, bool? isSpeakerOn}) {
    return VoiceState(
      status: status ?? this.status,
      isMuted: isMuted ?? this.isMuted,
      isSpeakerOn: isSpeakerOn ?? this.isSpeakerOn,
    );
  }
}

class VoiceNotifier extends StateNotifier<VoiceState> {
  Timer? _statusTimer;

  VoiceNotifier() : super(VoiceState(status: VoiceStatus.listening)) {
    _startAutoCycling();
  }

  void _startAutoCycling() {
    _statusTimer = Timer.periodic(const Duration(seconds: 4), (timer) {
      if (state.status == VoiceStatus.listening) {
        state = state.copyWith(status: VoiceStatus.thinking);
      } else if (state.status == VoiceStatus.thinking) {
        state = state.copyWith(status: VoiceStatus.speaking);
      } else {
        state = state.copyWith(status: VoiceStatus.listening);
      }
    });
  }

  void setStatus(VoiceStatus status) {
    _statusTimer?.cancel();
    state = state.copyWith(status: status);
    _startAutoCycling(); // Resume auto cycling
  }

  void toggleMute() {
    state = state.copyWith(isMuted: !state.isMuted);
  }

  void toggleSpeaker() {
    state = state.copyWith(isSpeakerOn: !state.isSpeakerOn);
  }

  @override
  void dispose() {
    _statusTimer?.cancel();
    super.dispose();
  }
}

final voiceProvider = StateNotifierProvider<VoiceNotifier, VoiceState>((ref) {
  return VoiceNotifier();
});
