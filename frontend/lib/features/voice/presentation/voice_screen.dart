import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/theme/theme_provider.dart';
import '../../../../core/localization/generated/app_localizations.dart';
import '../voice_provider.dart';
import 'widgets/animated_orb.dart';
import 'widgets/voice_wave.dart';

class VoiceAssistantScreen extends ConsumerWidget {
  const VoiceAssistantScreen({super.key});

  String _getStatusText(BuildContext context, VoiceStatus status) {
    switch (status) {
      case VoiceStatus.listening:
        return AppLocalizations.of(context)!.voiceStatusListening;
      case VoiceStatus.thinking:
        return AppLocalizations.of(context)!.voiceStatusThinking;
      case VoiceStatus.speaking:
        return AppLocalizations.of(context)!.voiceStatusSpeaking;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final voiceState = ref.watch(voiceProvider);
    final themeState = ref.watch(themeProvider);
    final statusText = _getStatusText(context, voiceState.status);

    return Scaffold(
      // Dynamic mood theme background
      backgroundColor: themeState.hasMoodSelected
          ? themeState.moodTheme.background
          : AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // Top Bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    tooltip: AppLocalizations.of(context)!.voiceBackTooltip,
                    icon: const Icon(
                      Icons.arrow_back_ios_new_rounded,
                      color: AppColors.text,
                    ),
                    onPressed: () {
                      if (context.canPop()) {
                        context.pop();
                      } else {
                        context.go('/home');
                      }
                    },
                  ),
                  Expanded(
                    child: Center(
                      child: Text(
                        statusText,
                        style: GoogleFonts.outfit(
                          color: AppColors.text,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.5,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                  // Audio options / share placeholder matching design
                  IconButton(
                    tooltip: AppLocalizations.of(context)!.voiceCameraTooltip,
                    icon: const Icon(
                      Icons.crop_free_rounded,
                      color: AppColors.text,
                    ),
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            AppLocalizations.of(context)!.voiceCameraSnackbar,
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),

            const Spacer(flex: 1),

            // Animated breathing morphing AI Orb
            AnimatedOrb(status: voiceState.status),

            const SizedBox(height: 48),

            // Description Subtitle
            Text(
              voiceState.status == VoiceStatus.listening
                  ? AppLocalizations.of(context)!.voiceDescListening
                  : voiceState.status == VoiceStatus.thinking
                  ? AppLocalizations.of(context)!.voiceDescThinking
                  : AppLocalizations.of(context)!.voiceDescSpeaking,
              style: GoogleFonts.quicksand(
                color: AppColors.textSecondary,
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),

            const Spacer(flex: 2),

            // Voice frequency waveform styled in yellow gold
            VoiceWave(status: voiceState.status),

            const SizedBox(height: 24),

            // Calling Controls Row
            Padding(
              padding: const EdgeInsets.only(bottom: 48.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Mute toggle button
                  _buildCallControlButton(
                    themeState,
                    icon: voiceState.isMuted
                        ? Icons.mic_off_rounded
                        : Icons.mic_none_rounded,
                    isActive: voiceState.isMuted,
                    activeColor: themeState.accentColor.withValues(alpha: 0.15),
                    tooltip: voiceState.isMuted
                        ? AppLocalizations.of(context)!.voiceUnmuteTooltip
                        : AppLocalizations.of(context)!.voiceMuteTooltip,
                    onPressed: () =>
                        ref.read(voiceProvider.notifier).toggleMute(),
                  ),
                  const SizedBox(width: 32),

                  // End Call Red Button
                  Tooltip(
                    message: AppLocalizations.of(context)!.voiceEndCallTooltip,
                    child: GestureDetector(
                      onTap: () {
                        if (context.canPop()) {
                          context.pop();
                        } else {
                          context.go('/home');
                        }
                      },
                      child: Container(
                        width: 68,
                        height: 68,
                        decoration: const BoxDecoration(
                          color: Colors.redAccent,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.redAccent,
                              blurRadius: 16,
                              offset: Offset(0, 4),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.call_end_rounded,
                          color: Colors.white,
                          size: 28,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 32),

                  // Speaker/Volume toggler
                  _buildCallControlButton(
                    themeState,
                    icon: voiceState.isSpeakerOn
                        ? Icons.volume_up_rounded
                        : Icons.volume_off_rounded,
                    isActive: !voiceState.isSpeakerOn,
                    activeColor: themeState.accentColor.withValues(alpha: 0.15),
                    tooltip: voiceState.isSpeakerOn
                        ? AppLocalizations.of(context)!.voiceSpeakerOffTooltip
                        : AppLocalizations.of(context)!.voiceSpeakerOnTooltip,
                    onPressed: () =>
                        ref.read(voiceProvider.notifier).toggleSpeaker(),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCallControlButton(
    ThemeState themeState, {
    required IconData icon,
    required bool isActive,
    required Color activeColor,
    required String tooltip,
    required VoidCallback onPressed,
  }) {
    return Container(
      width: 52,
      height: 52,
      decoration: BoxDecoration(
        color: isActive ? activeColor : Colors.white,
        shape: BoxShape.circle,
        border: Border.all(
          color: themeState.hasMoodSelected
              ? themeState.moodTheme.cardBorder
              : AppColors.lightCardBorder,
          width: 1.5,
        ),
      ),
      child: IconButton(
        tooltip: tooltip,
        icon: Icon(icon, color: AppColors.text, size: 22),
        onPressed: onPressed,
      ),
    );
  }
}
