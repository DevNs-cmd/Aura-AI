import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/theme/theme_provider.dart';
import '../../../core/widgets/mood_landscape_illustration.dart';
import '../../../core/localization/generated/app_localizations.dart';

class HeroCard extends ConsumerWidget {
  final VoidCallback onContinueTap;
  const HeroCard({super.key, required this.onContinueTap});

  String _getRecommendationText(BuildContext context, String mood) {
    final localizations = AppLocalizations.of(context)!;
    switch (mood) {
      case 'Happy':
        return localizations.recommendationHappy;
      case 'Calm':
        return localizations.recommendationCalm;
      case 'Motivated':
        return localizations.recommendationMotivated;
      case 'Relaxed':
        return localizations.recommendationRelaxed;
      case 'Reflective':
        return localizations.recommendationReflective;
      case 'Focused':
        return localizations.recommendationFocused;
      default:
        return localizations.recommendationDefault;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeState = ref.watch(themeProvider);
    final isDark = themeState.isDarkMode;
    final accentColor = themeState.accentColor;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: isDark
            ? const Color(0xFF1E1C24)
            : (themeState.hasMoodSelected
                  ? themeState.moodTheme.cardColor
                  : Colors.white),
        borderRadius: BorderRadius.circular(28), // Large soft rounded corner
        border: Border.all(
          color: isDark
              ? const Color(0xFF2C2834)
              : (themeState.hasMoodSelected
                    ? themeState.moodTheme.cardBorder
                    : AppColors.lightCardBorder),
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
          // Top Text Content Part
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      themeState.currentMood == 'none'
                          ? AppLocalizations.of(context)!.heroGreetingDefault
                          : AppLocalizations.of(
                              context,
                            )!.heroCompanionRecommendation,
                      style: GoogleFonts.outfit(
                        color: isDark
                            ? Colors.white70
                            : AppColors.lightTextSecondary,
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5,
                      ),
                    ),
                    _CompanionFace(accentColor: accentColor),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  _getRecommendationText(context, themeState.currentMood),
                  style: GoogleFonts.quicksand(
                    color: isDark ? Colors.white : AppColors.lightTextPrimary,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    height: 1.45,
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  height: 38,
                  child: ElevatedButton(
                    onPressed: onContinueTap,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: accentColor,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                    ),
                    child: Text(
                      AppLocalizations.of(context)!.heroLetsChat,
                      style: GoogleFonts.outfit(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Replicated landscape illustration banner at bottom
          MoodLandscapeIllustration(mood: themeState.currentMood, height: 110),
        ],
      ),
    );
  }
}

class _CompanionFace extends StatelessWidget {
  final Color accentColor;
  const _CompanionFace({required this.accentColor});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 34,
      height: 34,
      decoration: BoxDecoration(
        color: accentColor.withValues(alpha: 0.12),
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 3,
                  height: 3,
                  decoration: BoxDecoration(
                    color: accentColor,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 4),
                Container(
                  width: 3,
                  height: 3,
                  decoration: BoxDecoration(
                    color: accentColor,
                    shape: BoxShape.circle,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 3),
            Container(
              width: 7,
              height: 2.5,
              decoration: BoxDecoration(
                color: accentColor,
                borderRadius: const BorderRadius.vertical(
                  bottom: Radius.circular(2.5),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
