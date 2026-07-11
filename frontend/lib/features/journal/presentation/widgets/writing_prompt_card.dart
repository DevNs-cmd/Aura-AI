import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/theme_provider.dart';
import '../../../../core/widgets/mood_landscape_illustration.dart';
import '../../../../core/widgets/localized_button.dart';
import '../../../../core/localization/generated/app_localizations.dart';

class WritingPromptCard extends ConsumerWidget {
  final VoidCallback onStartWriting;
  final VoidCallback? onRefresh;
  final String promptText;

  const WritingPromptCard({
    super.key,
    required this.onStartWriting,
    this.onRefresh,
    this.promptText = "",
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeState = ref.watch(themeProvider);
    final isDark = themeState.isDarkMode;
    final accentColor = themeState.accentColor;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1C24) : Colors.white,
        borderRadius: BorderRadius.circular(
          28,
        ), // Consistent soft corner radius
        border: Border.all(
          color: isDark ? const Color(0xFF2C2834) : const Color(0xFFF6ECE2),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Text Content portion
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Row(
                        children: [
                          Icon(
                            Icons.lightbulb_outline_rounded,
                            color: isDark ? Colors.white70 : Colors.black87,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              AppLocalizations.of(
                                context,
                              )!.journalPromptCardHeader,
                              style: GoogleFonts.outfit(
                                color: isDark ? Colors.white60 : Colors.black54,
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (onRefresh != null) ...[
                      const SizedBox(width: 8),
                      GestureDetector(
                        onTap: onRefresh,
                        child: Icon(
                          Icons.refresh_rounded,
                          color: isDark ? Colors.white70 : Colors.black54,
                          size: 20,
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 14),
                Text(
                  promptText.isEmpty ||
                          promptText ==
                              "What's one small thing that brought you peace today, and why?"
                      ? AppLocalizations.of(context)!.journalPrompt1
                      : promptText,
                  style: GoogleFonts.quicksand(
                    color: isDark ? Colors.white : Colors.black87,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    height: 1.45,
                  ),
                ),
                const SizedBox(height: 16),
                LocalizedButton(
                  text: AppLocalizations.of(context)!.journalPromptCardBtn,
                  onPressed: onStartWriting,
                  height: 38,
                  width: 140,
                  textColor: Colors.white,
                  backgroundColor: accentColor,
                ),
              ],
            ),
          ),

          // Landscape vector illustration at bottom
          MoodLandscapeIllustration(mood: themeState.currentMood, height: 90),
        ],
      ),
    );
  }
}
