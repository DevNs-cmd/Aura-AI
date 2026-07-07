import 'package:flutter_test/flutter_test.dart';
import '../tool/arb_validator.dart';

void main() {
  group('ARB Validator Unit Tests', () {
    final Map<String, dynamic> template = {
      '@@locale': 'en',
      'appTitle': 'Aura AI',
      'settingsTitle': 'Settings',
      'homeGreeting': 'Hi, {name}',
      'documentsSelectedCount':
          '{count, plural, =1{1 selected} other{{count} selected}}',
    };

    test('Valid translation passes validation', () {
      final target = {
        '@@locale': 'hi',
        'appTitle': 'Aura AI', // Allowed untranslated brand name
        'settingsTitle': 'सेटिंग्स',
        'homeGreeting': 'नमस्ते, {name}',
        'documentsSelectedCount':
            '{count, plural, =1{1 चयनित} other{{count} चयनित}}',
      };

      final errors = ArbValidator.validateContent(
        filename: 'app_hi.arb',
        locale: 'hi',
        templateJson: template,
        targetJson: target,
      );

      expect(errors, isEmpty);
    });

    test('Detects invalid @@locale key value', () {
      final target = {
        '@@locale': 'en', // Should be 'hi'
        'appTitle': 'Aura AI',
        'settingsTitle': 'सेटिंग्स',
        'homeGreeting': 'नमस्ते, {name}',
        'documentsSelectedCount':
            '{count, plural, =1{1 चयनित} other{{count} चयनित}}',
      };

      final errors = ArbValidator.validateContent(
        filename: 'app_hi.arb',
        locale: 'hi',
        templateJson: template,
        targetJson: target,
      );

      expect(errors, hasLength(1));
      expect(errors.first.errorType, 'INVALID_LOCALE_ID');
      expect(errors.first.key, '@@locale');
    });

    test('Detects missing keys', () {
      final target = {
        '@@locale': 'hi',
        'appTitle': 'Aura AI',
        // 'settingsTitle' is missing
        'homeGreeting': 'नमस्ते, {name}',
        'documentsSelectedCount':
            '{count, plural, =1{1 चयनित} other{{count} चयनित}}',
      };

      final errors = ArbValidator.validateContent(
        filename: 'app_hi.arb',
        locale: 'hi',
        templateJson: template,
        targetJson: target,
      );

      expect(errors, hasLength(1));
      expect(errors.first.errorType, 'MISSING_KEY');
      expect(errors.first.key, 'settingsTitle');
    });

    test('Detects extra keys', () {
      final target = {
        '@@locale': 'hi',
        'appTitle': 'Aura AI',
        'settingsTitle': 'सेटिंग्स',
        'homeGreeting': 'नमस्ते, {name}',
        'documentsSelectedCount':
            '{count, plural, =1{1 चयनित} other{{count} चयनित}}',
        'extraKey': 'अनपेक्षित', // Extra key
      };

      final errors = ArbValidator.validateContent(
        filename: 'app_hi.arb',
        locale: 'hi',
        templateJson: template,
        targetJson: target,
      );

      expect(errors, hasLength(1));
      expect(errors.first.errorType, 'EXTRA_KEY');
      expect(errors.first.key, 'extraKey');
    });

    test('Detects empty translation values', () {
      final target = {
        '@@locale': 'hi',
        'appTitle': 'Aura AI',
        'settingsTitle': '', // Empty value
        'homeGreeting': 'नमस्ते, {name}',
        'documentsSelectedCount':
            '{count, plural, =1{1 चयनित} other{{count} चयनित}}',
      };

      final errors = ArbValidator.validateContent(
        filename: 'app_hi.arb',
        locale: 'hi',
        templateJson: template,
        targetJson: target,
      );

      expect(errors, hasLength(1));
      expect(errors.first.errorType, 'EMPTY_VALUE');
      expect(errors.first.key, 'settingsTitle');
    });

    test('Detects untranslated values that are not in the allowlist', () {
      final target = {
        '@@locale': 'hi',
        'appTitle': 'Aura AI', // Allowed
        'settingsTitle': 'Settings', // Untranslated, not allowed
        'homeGreeting': 'नमस्ते, {name}',
        'documentsSelectedCount':
            '{count, plural, =1{1 चयनित} other{{count} चयनित}}',
      };

      final errors = ArbValidator.validateContent(
        filename: 'app_hi.arb',
        locale: 'hi',
        templateJson: template,
        targetJson: target,
      );

      expect(errors, hasLength(1));
      expect(errors.first.errorType, 'UNTRANSLATED_VALUE');
      expect(errors.first.key, 'settingsTitle');
    });

    test('Detects placeholder name mismatches', () {
      final target = {
        '@@locale': 'hi',
        'appTitle': 'Aura AI',
        'settingsTitle': 'सेटिंग्स',
        'homeGreeting': 'नमस्ते, {username}', // name vs username
        'documentsSelectedCount':
            '{count, plural, =1{1 चयनित} other{{count} चयनित}}',
      };

      final errors = ArbValidator.validateContent(
        filename: 'app_hi.arb',
        locale: 'hi',
        templateJson: template,
        targetJson: target,
      );

      expect(errors, hasLength(1));
      expect(errors.first.errorType, 'PLACEHOLDER_MISMATCH');
      expect(errors.first.key, 'homeGreeting');
    });

    test('Detects placeholder quantity mismatches', () {
      final target = {
        '@@locale': 'hi',
        'appTitle': 'Aura AI',
        'settingsTitle': 'सेटिंग्स',
        'homeGreeting': 'नमस्ते', // Missing placeholder {name}
        'documentsSelectedCount':
            '{count, plural, =1{1 चयनित} other{{count} चयनित}}',
      };

      final errors = ArbValidator.validateContent(
        filename: 'app_hi.arb',
        locale: 'hi',
        templateJson: template,
        targetJson: target,
      );

      expect(errors, hasLength(1));
      expect(errors.first.errorType, 'PLACEHOLDER_MISMATCH');
      expect(errors.first.key, 'homeGreeting');
    });
  });
}
