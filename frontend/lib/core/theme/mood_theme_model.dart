import 'package:flutter/material.dart';
import '../localization/generated/app_localizations.dart';

/// Defines a complete per-mood color palette model.
///
/// Each mood in Aura AI has a distinct visual identity expressed through
/// a curated set of colors for backgrounds, cards, buttons, charts, and icons.
class MoodThemeModel {
  final String name;
  final String emoji;
  final String description;
  final Color primary;
  final Color secondary;
  final Color accent;
  final Color background;
  final Color cardColor;
  final Color cardBorder;
  final List<Color> buttonGradient;
  final Color chartColor;
  final Color iconColor;
  final List<Color> backgroundGradient;

  const MoodThemeModel({
    required this.name,
    required this.emoji,
    required this.description,
    required this.primary,
    required this.secondary,
    required this.accent,
    required this.background,
    required this.cardColor,
    required this.cardBorder,
    required this.buttonGradient,
    required this.chartColor,
    required this.iconColor,
    required this.backgroundGradient,
  });

  /// All supported mood names.
  static const List<String> allMoods = [
    'Happy',
    'Calm',
    'Motivated',
    'Relaxed',
    'Reflective',
    'Focused',
    'Tired',
    'Inspired',
  ];

  /// Returns the full [MoodThemeModel] palette for the given [mood] name.
  ///
  /// Falls back to the **Happy** palette if the mood is unrecognised.
  static MoodThemeModel fromMoodName(String mood) {
    switch (mood) {
      case 'Happy':
        return const MoodThemeModel(
          name: 'Happy',
          emoji: '😊',
          description: 'Bright and warm — radiate positivity.',
          primary: Color(0xFFFFB84D),
          secondary: Color(0xFFFF9A3C),
          accent: Color(0xFFFFCB6B),
          background: Color(0xFFFFF7EF),
          cardColor: Color(0xFFFFFDF8),
          cardBorder: Color(0xFFF6ECE2),
          buttonGradient: [Color(0xFFFFB84D), Color(0xFFFF9A3C)],
          chartColor: Color(0xFFFF9A3C),
          iconColor: Color(0xFFFFB84D),
          backgroundGradient: [Color(0xFFFFF9F2), Color(0xFFFFE4C4)],
        );

      case 'Calm':
        return const MoodThemeModel(
          name: 'Calm',
          emoji: '😌',
          description: 'Soft blues for a peaceful mind.',
          primary: Color(0xFF7C9EFF),
          secondary: Color(0xFFA3D4FF),
          accent: Color(0xFF8BB5FF),
          background: Color(0xFFF0F4FF),
          cardColor: Color(0xFFF7F9FF),
          cardBorder: Color(0xFFE4EBFA),
          buttonGradient: [Color(0xFF7C9EFF), Color(0xFF5B7FFF)],
          chartColor: Color(0xFF5B7FFF),
          iconColor: Color(0xFF7C9EFF),
          backgroundGradient: [Color(0xFFF4F6FF), Color(0xFFD6E0FF)],
        );

      case 'Motivated':
        return const MoodThemeModel(
          name: 'Motivated',
          emoji: '💪',
          description: 'Energising greens to fuel your drive.',
          primary: Color(0xFF5CB85C),
          secondary: Color(0xFF8ED957),
          accent: Color(0xFF7ECDA0),
          background: Color(0xFFF0F9F0),
          cardColor: Color(0xFFF8FFF8),
          cardBorder: Color(0xFFDFF0DF),
          buttonGradient: [Color(0xFF5CB85C), Color(0xFF449D44)],
          chartColor: Color(0xFF449D44),
          iconColor: Color(0xFF5CB85C),
          backgroundGradient: [Color(0xFFF3FCF1), Color(0xFFD4F0D4)],
        );

      case 'Relaxed':
        return const MoodThemeModel(
          name: 'Relaxed',
          emoji: '🧘',
          description: 'Gentle purples for easy-going vibes.',
          primary: Color(0xFFA78BFA),
          secondary: Color(0xFFC4B5FD),
          accent: Color(0xFFB49BFF),
          background: Color(0xFFF5F0FF),
          cardColor: Color(0xFFFAF7FF),
          cardBorder: Color(0xFFE8E0F5),
          buttonGradient: [Color(0xFFA78BFA), Color(0xFF8B5CF6)],
          chartColor: Color(0xFF8B5CF6),
          iconColor: Color(0xFFA78BFA),
          backgroundGradient: [Color(0xFFF7F4FF), Color(0xFFE4DBFF)],
        );

      case 'Reflective':
        return const MoodThemeModel(
          name: 'Reflective',
          emoji: '🪞',
          description: 'Soft pinks for peaceful self-reflection.',
          primary: Color(0xFFEC4899),
          secondary: Color(0xFFFBCFE8),
          accent: Color(0xFFF472B6),
          background: Color(0xFFFFF1F6),
          cardColor: Color(0xFFFFFAFC),
          cardBorder: Color(0xFFFCE7F3),
          buttonGradient: [Color(0xFFEC4899), Color(0xFFBE185D)],
          chartColor: Color(0xFFBE185D),
          iconColor: Color(0xFFEC4899),
          backgroundGradient: [Color(0xFFFFF5F8), Color(0xFFFBCFE8)],
        );

      case 'Focused':
        return const MoodThemeModel(
          name: 'Focused',
          emoji: '🎯',
          description: 'Bold orange and blue for laser focus.',
          primary: Color(0xFFFF7A45),
          secondary: Color(0xFF7C8CFF),
          accent: Color(0xFF4E8CFF),
          background: Color(0xFFFFF7EF),
          cardColor: Color(0xFFFFFFFF),
          cardBorder: Color(0xFFF6ECE2),
          buttonGradient: [Color(0xFFFF7A45), Color(0xFFE65C2B)],
          chartColor: Color(0xFFFF7A45),
          iconColor: Color(0xFFFF7A45),
          backgroundGradient: [Color(0xFFFFF3EE), Color(0xFFFFD9C7)],
        );

      case 'Tired':
        return const MoodThemeModel(
          name: 'Tired',
          emoji: '😴',
          description: 'Soft greys for low-energy moments.',
          primary: Color(0xFF8E9AAF),
          secondary: Color(0xFFB8B8D0),
          accent: Color(0xFF7E8FAF),
          background: Color(0xFFF5F5F8),
          cardColor: Color(0xFFF9F9FC),
          cardBorder: Color(0xFFE8E8F0),
          buttonGradient: [Color(0xFF8E9AAF), Color(0xFF6E7A8F)],
          chartColor: Color(0xFF6E7A8F),
          iconColor: Color(0xFF8E9AAF),
          backgroundGradient: [Color(0xFFF5F5F8), Color(0xFFE0E0EA)],
        );

      case 'Inspired':
        return const MoodThemeModel(
          name: 'Inspired',
          emoji: '✨',
          description: 'Deep premium reds to spark creative flow.',
          primary: Color(0xFFFF3B30),
          secondary: Color(0xFFFF5E55),
          accent: Color(0xFFFF7B73),
          background: Color(0xFFFFF2F1),
          cardColor: Color(0xFFFFF9F8),
          cardBorder: Color(0xFFFDE1E0),
          buttonGradient: [Color(0xFFFF3B30), Color(0xFFC91E1E)],
          chartColor: Color(0xFFC91E1E),
          iconColor: Color(0xFFFF3B30),
          backgroundGradient: [Color(0xFFFFF5F4), Color(0xFFFFD1CF)],
        );

      default:
        // Fallback to the Happy palette.
        return fromMoodName('Happy');
    }
  }

  /// Returns the localized name of the mood.
  String getLocalizedName(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    if (localizations == null) return name;
    switch (name) {
      case 'Happy':
        return localizations.moodNameHappy;
      case 'Calm':
        return localizations.moodNameCalm;
      case 'Motivated':
        return localizations.moodNameMotivated;
      case 'Relaxed':
        return localizations.moodNameRelaxed;
      case 'Reflective':
        return localizations.moodNameReflective;
      case 'Focused':
        return localizations.moodNameFocused;
      case 'Tired':
        return localizations.moodNameTired;
      case 'Inspired':
        return localizations.moodNameInspired;
      default:
        return name;
    }
  }

  /// Returns the localized description of the mood.
  String getLocalizedDescription(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    if (localizations == null) return description;
    switch (name) {
      case 'Happy':
        return localizations.moodDescHappy;
      case 'Calm':
        return localizations.moodDescCalm;
      case 'Motivated':
        return localizations.moodDescMotivated;
      case 'Relaxed':
        return localizations.moodDescRelaxed;
      case 'Reflective':
        return localizations.moodDescReflective;
      case 'Focused':
        return localizations.moodDescFocused;
      case 'Tired':
        return localizations.moodDescTired;
      case 'Inspired':
        return localizations.moodDescInspired;
      default:
        return description;
    }
  }
}
