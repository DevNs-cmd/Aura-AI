import 'package:flutter/material.dart';

/// Immutable model representing a supported language in the application.
class SupportedLanguage {
  final Locale locale;
  final String nativeName;
  final String englishName;

  const SupportedLanguage({
    required this.locale,
    required this.nativeName,
    required this.englishName,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SupportedLanguage &&
          runtimeType == other.runtimeType &&
          locale == other.locale &&
          nativeName == other.nativeName &&
          englishName == other.englishName;

  @override
  int get hashCode =>
      locale.hashCode ^ nativeName.hashCode ^ englishName.hashCode;
}

/// Centralized list of supported languages.
/// This is the single source of truth for supported language metadata.
const List<SupportedLanguage> supportedLanguages = [
  SupportedLanguage(
    locale: Locale('en'),
    nativeName: 'English',
    englishName: 'English',
  ),
  SupportedLanguage(
    locale: Locale('hi'),
    nativeName: 'हिन्दी',
    englishName: 'Hindi',
  ),
  SupportedLanguage(
    locale: Locale('es'),
    nativeName: 'Español',
    englishName: 'Spanish',
  ),
  SupportedLanguage(
    locale: Locale('fr'),
    nativeName: 'Français',
    englishName: 'French',
  ),
  SupportedLanguage(
    locale: Locale('de'),
    nativeName: 'Deutsch',
    englishName: 'German',
  ),
];

/// Helper methods to interact with the supported languages registry.
class SupportedLanguagesRegistry {
  /// Returns the default fallback language (first in the list).
  static SupportedLanguage get defaultLanguage => supportedLanguages.first;

  /// Looks up a [SupportedLanguage] by its language code.
  /// Returns null if the code is not supported.
  static SupportedLanguage? lookupByCode(String code) {
    final normalized = code.toLowerCase().trim();
    for (final lang in supportedLanguages) {
      if (lang.locale.languageCode == normalized ||
          lang.englishName.toLowerCase() == normalized ||
          lang.nativeName.toLowerCase() == normalized) {
        return lang;
      }
    }
    return null;
  }

  /// Looks up a [SupportedLanguage] by its [Locale].
  /// Returns null if the locale is not supported.
  static SupportedLanguage? lookupByLocale(Locale locale) {
    return lookupByCode(locale.languageCode);
  }

  /// Checks if a language code is supported in the registry.
  static bool isSupportedCode(String code) {
    return lookupByCode(code) != null;
  }

  /// Checks if a [Locale] is supported in the registry.
  static bool isSupportedLocale(Locale locale) {
    return lookupByLocale(locale) != null;
  }
}
