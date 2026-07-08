import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/theme/theme_provider.dart';
import '../../../core/theme/mood_theme_model.dart';
import '../../../core/localization/quote_service.dart';
import '../../../core/localization/generated/app_localizations.dart';

class DynamicInspirationCard extends ConsumerStatefulWidget {
  const DynamicInspirationCard({super.key});

  @override
  ConsumerState<DynamicInspirationCard> createState() => _DynamicInspirationCardState();
}

class _DynamicInspirationCardState extends ConsumerState<DynamicInspirationCard> with SingleTickerProviderStateMixin {
  late final AnimationController _floatController;
  late final Animation<double> _floatAnimation;

  @override
  void initState() {
    super.initState();
    _floatController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat(reverse: true);

    _floatAnimation = Tween<double>(begin: -4, end: 4).animate(
      CurvedAnimation(parent: _floatController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _floatController.dispose();
    super.dispose();
  }

  String _getGreetingText(BuildContext context, String timePeriod) {
    final l10n = AppLocalizations.of(context)!;
    switch (timePeriod) {
      case 'Morning':
        return l10n.greetingMorning;
      case 'Afternoon':
        return l10n.greetingAfternoon;
      case 'Evening':
        return l10n.greetingEvening;
      case 'Night':
        return l10n.greetingNight;
      default:
        return l10n.greetingMorning;
    }
  }

  String _getThemeEmoji(String theme) {
    switch (theme) {
      case 'Happy':
        return '😊';
      case 'Calm':
        return '☁️';
      case 'Motivated':
        return '🌱';
      case 'Relaxed':
        return '🌙';
      case 'Reflective':
        return '🌧️';
      case 'Focused':
        return '⚡';
      case 'Tired':
        return '😴';
      case 'Inspired':
        return '❤️';
      default:
        return '😊';
    }
  }

  String _getLocalizedThemeName(BuildContext context, String theme) {
    final l10n = AppLocalizations.of(context)!;
    switch (theme) {
      case 'Happy':
        return l10n.moodNameHappy;
      case 'Calm':
        return l10n.moodNameCalm;
      case 'Motivated':
        return l10n.moodNameMotivated;
      case 'Relaxed':
        return l10n.moodNameRelaxed;
      case 'Reflective':
        return l10n.moodNameReflective;
      case 'Focused':
        return l10n.moodNameFocused;
      case 'Tired':
        return l10n.moodNameTired;
      case 'Inspired':
        return l10n.moodNameInspired;
      default:
        return theme;
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeState = ref.watch(themeProvider);
    final isDark = themeState.isDarkMode;
    final activeTheme = themeState.currentMood == 'none' ? 'Happy' : themeState.currentMood;
    final moodTheme = MoodThemeModel.fromMoodName(activeTheme);

    final quoteServiceAsync = ref.watch(quoteServiceProvider(activeTheme));

    return AnimatedBuilder(
      animation: _floatAnimation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, _floatAnimation.value),
          child: child,
        );
      },
      child: quoteServiceAsync.when(
        data: (quoteService) {
          final now = DateTime.now();
          final timePeriod = quoteService.getTimePeriod(now);
          final quoteModel = quoteService.getQuote(now);

          return AnimatedContainer(
            duration: const Duration(milliseconds: 500),
            width: double.infinity,
            constraints: const BoxConstraints(minHeight: 180),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: isDark
                    ? [const Color(0xFF1E1C24), const Color(0xFF18161D)]
                    : moodTheme.backgroundGradient,
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(28),
              border: Border.all(
                color: isDark ? const Color(0xFF2C2834) : moodTheme.cardBorder,
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: isDark
                      ? Colors.black.withValues(alpha: 0.15)
                      : moodTheme.primary.withValues(alpha: 0.15),
                  blurRadius: 20,
                  spreadRadius: 1,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Stack(
              children: [
                // Top-right glowing orb decoration
                Positioned(
                  top: -20,
                  right: -20,
                  child: Container(
                    key: const ValueKey('glow-orb'),
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: moodTheme.primary.withValues(alpha: 0.2),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(22),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header Row
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _getGreetingText(context, timePeriod),
                                style: GoogleFonts.outfit(
                                  color: isDark ? Colors.white : moodTheme.primary,
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 0.5,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                quoteModel.subtitle,
                                style: GoogleFonts.quicksand(
                                  color: isDark ? Colors.white60 : AppColors.lightTextSecondary,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                          Container(
                            width: 38,
                            height: 38,
                            decoration: BoxDecoration(
                              color: isDark
                                  ? const Color(0xFF2C2834)
                                  : moodTheme.secondary.withValues(alpha: 0.2),
                              shape: BoxShape.circle,
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              _getThemeEmoji(activeTheme),
                              style: const TextStyle(fontSize: 18),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),

                      // Quote Body with Smooth Fade Switcher
                      AnimatedSwitcher(
                        duration: const Duration(milliseconds: 400),
                        transitionBuilder: (Widget child, Animation<double> animation) {
                          return FadeTransition(
                            opacity: animation,
                            child: SlideTransition(
                              position: Tween<Offset>(
                                begin: const Offset(0.0, 0.05),
                                end: Offset.zero,
                              ).animate(animation),
                              child: child,
                            ),
                          );
                        },
                        child: Text(
                          quoteModel.quote,
                          key: ValueKey<String>(quoteModel.quote),
                          style: GoogleFonts.outfit(
                            color: isDark ? Colors.white : AppColors.lightTextPrimary,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            height: 1.45,
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Bottom Metadata Info Row
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.wb_sunny_rounded,
                                size: 13,
                                color: isDark ? Colors.white60 : AppColors.lightTextTertiary,
                              ),
                              const SizedBox(width: 5),
                              Text(
                                _getLocalizedThemeName(context, activeTheme),
                                style: GoogleFonts.outfit(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: isDark ? Colors.white60 : moodTheme.primary,
                                ),
                              ),
                            ],
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: isDark
                                  ? const Color(0xFF2C2834)
                                  : moodTheme.primary.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              AppLocalizations.of(context)!.navExplore,
                              style: GoogleFonts.outfit(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: isDark ? Colors.white70 : moodTheme.primary,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
        loading: () => Container(
          width: double.infinity,
          height: 180,
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1E1C24) : Colors.white,
            borderRadius: BorderRadius.circular(28),
            border: Border.all(
              color: isDark ? const Color(0xFF2C2834) : AppColors.lightCardBorder,
              width: 1.5,
            ),
          ),
          alignment: Alignment.center,
          child: CircularProgressIndicator(
            color: moodTheme.primary,
          ),
        ),
        error: (err, stack) => Container(
          width: double.infinity,
          height: 180,
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1E1C24) : Colors.white,
            borderRadius: BorderRadius.circular(28),
            border: Border.all(
              color: Colors.redAccent.withValues(alpha: 0.5),
              width: 1.5,
            ),
          ),
          alignment: Alignment.center,
          padding: const EdgeInsets.all(16),
          child: Text(
            'Error loading inspiration: $err',
            style: GoogleFonts.quicksand(color: Colors.redAccent, fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }
}
