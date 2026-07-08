import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'supported_languages.dart';

class LocaleNotifier extends StateNotifier<Locale> {
  static const String prefKey = 'language';
  SharedPreferences? _prefs;

  LocaleNotifier() : super(SupportedLanguagesRegistry.defaultLanguage.locale) {
    _loadPersistedLocale();
  }

  Future<void> _loadPersistedLocale() async {
    _prefs = await SharedPreferences.getInstance();
    final savedCode = _prefs?.getString(prefKey);
    if (savedCode != null && mounted) {
      state = _parseLocale(savedCode);
    }
  }

  Locale _parseLocale(String value) {
    final lang = SupportedLanguagesRegistry.lookupByCode(value);
    if (lang != null) {
      return lang.locale;
    }
    return SupportedLanguagesRegistry.defaultLanguage.locale;
  }

  Future<void> setLocale(Locale locale) async {
    if (SupportedLanguagesRegistry.isSupportedLocale(locale)) {
      state = locale;
      _prefs ??= await SharedPreferences.getInstance();
      await _prefs?.setString(prefKey, locale.languageCode);
    }
  }

  Future<void> setLanguageByName(String name) async {
    final locale = _parseLocale(name);
    await setLocale(locale);
  }

  bool isSupported(String code) {
    return SupportedLanguagesRegistry.isSupportedCode(code);
  }
}

final localeProvider = StateNotifierProvider<LocaleNotifier, Locale>((ref) {
  return LocaleNotifier();
});
