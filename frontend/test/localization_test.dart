import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:aura_ai/core/localization/locale_controller.dart';
import 'package:aura_ai/core/localization/supported_languages.dart';
import 'package:aura_ai/core/localization/generated/app_localizations.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('Localization and Language Tests', () {
    test('Registry locales exactly match generated supported locales', () {
      final registryLocales = supportedLanguages.map((l) => l.locale).toSet();
      final generatedLocales = AppLocalizations.supportedLocales.toSet();
      expect(
        registryLocales,
        generatedLocales,
        reason:
            'Mismatch between registered locales and generated locales. '
            'Please ensure all translation files have a registry entry, and vice-versa.',
      );
    });

    test('Registry metadata is valid and default locale exists', () {
      final codes = <String>{};
      for (final lang in supportedLanguages) {
        expect(lang.nativeName, isNotEmpty);
        expect(lang.englishName, isNotEmpty);
        expect(
          codes.add(lang.locale.languageCode),
          true,
          reason:
              'Locale code ${lang.locale.languageCode} is duplicated in registry.',
        );
      }

      final defaultLang = SupportedLanguagesRegistry.defaultLanguage;
      expect(supportedLanguages.contains(defaultLang), true);
    });

    test(
      'LocaleNotifier accepts every registry locale and rejects unknown',
      () async {
        final container = ProviderContainer();
        addTearDown(container.dispose);
        final notifier = container.read(localeProvider.notifier);

        for (final lang in supportedLanguages) {
          expect(notifier.isSupported(lang.locale.languageCode), true);

          await notifier.setLocale(lang.locale);
          expect(container.read(localeProvider), lang.locale);

          // Parsing works for native name, English name, and code
          await notifier.setLanguageByName(lang.nativeName);
          expect(container.read(localeProvider), lang.locale);

          await notifier.setLanguageByName(lang.englishName);
          expect(container.read(localeProvider), lang.locale);

          await notifier.setLanguageByName(lang.locale.languageCode);
          expect(container.read(localeProvider), lang.locale);
        }

        expect(notifier.isSupported('xx'), false);

        final current = container.read(localeProvider);
        await notifier.setLocale(const Locale('xx'));
        expect(
          container.read(localeProvider),
          current,
          reason: 'LocaleNotifier accepted an unregistered/invalid locale.',
        );
      },
    );

    test('Every locale can resolve AppLocalizations', () async {
      for (final lang in supportedLanguages) {
        expect(AppLocalizations.delegate.isSupported(lang.locale), true);
        final localizations = await AppLocalizations.delegate.load(lang.locale);
        expect(localizations.appTitle, isNotEmpty);
      }
    });

    test(
      'Locale persistence round-trip succeeds for every registered locale',
      () async {
        for (final lang in supportedLanguages) {
          SharedPreferences.setMockInitialValues({});

          // 1. Set language on notifier
          final container1 = ProviderContainer();
          final notifier1 = container1.read(localeProvider.notifier);
          await notifier1.setLocale(lang.locale);
          container1.dispose();

          // 2. Recreate provider state
          final container2 = ProviderContainer();
          addTearDown(container2.dispose);
          container2.read(localeProvider);
          await Future.delayed(const Duration(milliseconds: 50));

          // 3. Verify restored locale
          final restoredLocale = container2.read(localeProvider);
          expect(restoredLocale, lang.locale);

          // 4. Verify display names match
          final langInfo = SupportedLanguagesRegistry.lookupByLocale(
            restoredLocale,
          );
          expect(langInfo, lang);
        }
      },
    );
  });
}
