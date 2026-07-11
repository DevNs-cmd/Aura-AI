import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../constants/app_colors.dart';
import 'mood_theme_model.dart';

class ThemeState {
  final bool isDarkMode;
  final String
  currentMood; // 'Happy', 'Calm', 'Motivated', 'Relaxed', 'Reflective', 'Focused', 'Tired', 'Inspired', 'none'

  ThemeState({required this.isDarkMode, required this.currentMood});

  ThemeState copyWith({bool? isDarkMode, String? currentMood}) {
    return ThemeState(
      isDarkMode: isDarkMode ?? this.isDarkMode,
      currentMood: currentMood ?? this.currentMood,
    );
  }

  /// Whether the user has previously selected a mood
  bool get hasMoodSelected => currentMood != 'none';

  /// Returns the full mood theme palette for the current mood
  MoodThemeModel get moodTheme => MoodThemeModel.fromMoodName(currentMood);

  Color get accentColor {
    if (hasMoodSelected) {
      return moodTheme.primary;
    }
    return AppColors.primary; // Standard Amber accent when no mood set
  }

  List<Color> get gradientColors {
    if (hasMoodSelected) {
      return moodTheme.backgroundGradient;
    }
    return [
      const Color(0xFFFFDFA6),
      AppColors.primary,
    ]; // Default warm gradient
  }
}

class ThemeNotifier extends StateNotifier<ThemeState> {
  SharedPreferences? _prefs;

  ThemeNotifier() : super(ThemeState(isDarkMode: false, currentMood: 'none')) {
    _initPrefs();
  }

  Future<void> _initPrefs() async {
    _prefs = await SharedPreferences.getInstance();
    final isDark = _prefs?.getBool('is_dark_mode') ?? false;
    final mood = _prefs?.getString('current_mood') ?? 'none';
    state = ThemeState(isDarkMode: isDark, currentMood: mood);
  }

  Future<void> toggleDarkMode() async {
    final newIsDark = !state.isDarkMode;
    state = state.copyWith(isDarkMode: newIsDark);
    await _prefs?.setBool('is_dark_mode', newIsDark);
  }

  Future<void> setDarkMode(bool isDark) async {
    state = state.copyWith(isDarkMode: isDark);
    await _prefs?.setBool('is_dark_mode', isDark);
  }

  Future<void> setMoodTheme(String mood) async {
    state = state.copyWith(currentMood: mood);
    await _prefs?.setString('current_mood', mood);
  }

  Future<void> clearMoodTheme() async {
    state = state.copyWith(currentMood: 'none');
    await _prefs?.setString('current_mood', 'none');
  }
}

final themeProvider = StateNotifierProvider<ThemeNotifier, ThemeState>((ref) {
  return ThemeNotifier();
});
