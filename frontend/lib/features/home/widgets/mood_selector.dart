import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/theme/theme_provider.dart';
import '../../../core/widgets/bouncing_widget.dart';
import '../../../core/localization/generated/app_localizations.dart';

class MoodItem {
  final String label;
  final String emoji;
  const MoodItem({required this.label, required this.emoji});
}

class MoodSelector extends ConsumerWidget {
  const MoodSelector({super.key});

  final List<MoodItem> _moods = const [
    MoodItem(label: 'Happy', emoji: '😊'),
    MoodItem(label: 'Calm', emoji: '☁️'),
    MoodItem(label: 'Motivated', emoji: '🌱'),
    MoodItem(label: 'Relaxed', emoji: '🌙'),
    MoodItem(label: 'Reflective', emoji: '🌧️'),
    MoodItem(label: 'Focused', emoji: '⚡'),
  ];

  String _getLocalMoodName(BuildContext context, String label) {
    final l10n = AppLocalizations.of(context);
    if (l10n == null) return label;
    switch (label) {
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
      default:
        return label;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeState = ref.watch(themeProvider);
    final isDark = themeState.isDarkMode;
    final primaryColor = themeState.accentColor;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppLocalizations.of(context)!.homeFeelingQuestion,
          style: GoogleFonts.outfit(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.white : AppColors.lightTextPrimary,
          ),
        ),
        const SizedBox(height: 16),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          clipBehavior: Clip.none,
          child: Row(
            children: List.generate(_moods.length, (index) {
              final mood = _moods[index];
              final isSelected = themeState.currentMood == mood.label;

              return Padding(
                padding: const EdgeInsets.only(right: 14),
                child: BouncingWidget(
                  onTap: () {
                    ref.read(themeProvider.notifier).setMoodTheme(mood.label);
                  },
                  child: Column(
                    children: [
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 250),
                        width: 58,
                        height: 72,
                        decoration: BoxDecoration(
                          color: isSelected
                              ? primaryColor
                              : (isDark
                                    ? const Color(0xFF1E1C24)
                                    : Colors.white),
                          borderRadius: BorderRadius.circular(20),
                          border: isSelected
                              ? null
                              : Border.all(
                                  color: isDark
                                      ? const Color(0xFF2C2834)
                                      : AppColors.lightCardBorder,
                                  width: 1.5,
                                ),
                          boxShadow: [
                            BoxShadow(
                              color: isSelected
                                  ? primaryColor.withValues(alpha: 0.25)
                                  : Colors.black.withValues(alpha: 0.02),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          mood.emoji,
                          style: const TextStyle(fontSize: 26),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _getLocalMoodName(context, mood.label),
                        style: GoogleFonts.quicksand(
                          fontSize: 12,
                          fontWeight: isSelected
                              ? FontWeight.bold
                              : FontWeight.w700,
                          color: isSelected
                              ? primaryColor
                              : (isDark
                                    ? Colors.white60
                                    : AppColors.lightTextSecondary),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
          ),
        ),
      ],
    );
  }
}
