import 'dart:convert';
import 'dart:io';

class ValidationError {
  final String file;
  final String locale;
  final String key;
  final String errorType;
  final String expected;
  final String actual;

  ValidationError({
    required this.file,
    required this.locale,
    required this.key,
    required this.errorType,
    required this.expected,
    required this.actual,
  });

  @override
  String toString() {
    return 'FILE: $file\n'
        'LOCALE: $locale\n'
        'KEY: $key\n'
        'ERROR TYPE: $errorType\n'
        'EXPECTED: $expected\n'
        'ACTUAL: $actual\n'
        '----------------------------------------';
  }
}

class ArbValidator {
  static final RegExp placeholderRegex = RegExp(r'\{([^}]+)\}');

  // Brand names, technology models, and standard patterns that are allowed to remain identical to English
  static const Set<String> untranslatedAllowlist = {
    'Aura AI',
    'Aura Companion',
    'GPT-4o',
    'Online • GPT-4o',
    'yMMMd',
    'MMM d, y',
    'EEE',
    'd',
    'OCR',
    'v1.0',
    'PDF',
    'DOC',
    'TXT',
    'M',
    'T',
    'W',
    'F',
    'S',
    // Cross-language identical cognates (legitimate same-word translations)
    'Notifications',
    'Version',
    'Chat',
    'Vision',
    'Aura Vision',
    'Journal',
    'Email',
    'Nature',
    'Text',
    'Laptop',
    'Okay',
    'Name',
    'Corporate',
    'Tech',
    'Lorem ipsum dolor sit amet, consectetur adipiscing elit. Aliquam elementum dolor ac nulla tristique condimentum. In sed est et lectus accumsan fringilla. Nunc lobortis ipsum elit, id pellentesque risus molestie id. Nullam vel nulla et ante volutpat tempor. Sed vel leo purus. Praesent sit amet ipsum sit amet arcu dignissim hendrerit. Duis finibus, mi sed finibus scelerisque, sapien lorem pretium tellus, ut pellentesque risus elit non ligula.',
  };

  /// Parses all actual placeholder variable names from a string value, including ICU structures.
  static Set<String> extractPlaceholders(String value) {
    final Set<String> placeholders = {};
    final matches = placeholderRegex.allMatches(value);
    for (final match in matches) {
      final content = match.group(1)!;
      if (content.contains(',plural,') ||
          content.contains(',select,') ||
          content.contains(', plural,') ||
          content.contains(', select,')) {
        final commaIdx = content.indexOf(',');
        if (commaIdx != -1) {
          placeholders.add(content.substring(0, commaIdx).trim());
        }
      } else {
        placeholders.add(content.trim());
      }
    }
    return placeholders;
  }

  /// Validates a single ARB file content against the English template map.
  static List<ValidationError> validateContent({
    required String filename,
    required String locale,
    required Map<String, dynamic> templateJson,
    required Map<String, dynamic> targetJson,
  }) {
    final List<ValidationError> errors = [];

    // 1. Verify @@locale key if present
    final targetLocale = targetJson['@@locale'];
    if (targetLocale != null && targetLocale != locale) {
      errors.add(
        ValidationError(
          file: filename,
          locale: locale,
          key: '@@locale',
          errorType: 'INVALID_LOCALE_ID',
          expected: locale,
          actual: targetLocale.toString(),
        ),
      );
    }

    final templateKeys = templateJson.keys
        .where((k) => !k.startsWith('@'))
        .toSet();
    final targetKeys = targetJson.keys.where((k) => !k.startsWith('@')).toSet();

    // 2. Check for missing keys
    for (final key in templateKeys) {
      if (!targetKeys.contains(key)) {
        errors.add(
          ValidationError(
            file: filename,
            locale: locale,
            key: key,
            errorType: 'MISSING_KEY',
            expected: 'Key should exist in target ARB',
            actual: 'Key is missing',
          ),
        );
        continue;
      }

      final templateVal = templateJson[key].toString();
      final targetVal = targetJson[key].toString();

      // 3. Check for empty values
      if (targetVal.trim().isEmpty) {
        errors.add(
          ValidationError(
            file: filename,
            locale: locale,
            key: key,
            errorType: 'EMPTY_VALUE',
            expected: 'Non-empty translation',
            actual: 'Empty or whitespace string',
          ),
        );
        continue;
      }

      // 4. Check for untranslated values
      if (templateVal == targetVal &&
          !untranslatedAllowlist.contains(templateVal)) {
        errors.add(
          ValidationError(
            file: filename,
            locale: locale,
            key: key,
            errorType: 'UNTRANSLATED_VALUE',
            expected: 'Translated value (different from English)',
            actual: targetVal,
          ),
        );
      }

      // 5. Check placeholder consistency
      final templatePlaceholders = extractPlaceholders(templateVal);
      final targetPlaceholders = extractPlaceholders(targetVal);

      if (templatePlaceholders.length != targetPlaceholders.length ||
          !templatePlaceholders.containsAll(targetPlaceholders)) {
        errors.add(
          ValidationError(
            file: filename,
            locale: locale,
            key: key,
            errorType: 'PLACEHOLDER_MISMATCH',
            expected: 'Placeholders: ${templatePlaceholders.join(', ')}',
            actual: 'Placeholders: ${targetPlaceholders.join(', ')}',
          ),
        );
      }
    }

    // 6. Check for extra keys in target
    for (final key in targetKeys) {
      if (!templateKeys.contains(key)) {
        errors.add(
          ValidationError(
            file: filename,
            locale: locale,
            key: key,
            errorType: 'EXTRA_KEY',
            expected: 'Key should not exist (not in app_en.arb)',
            actual: 'Key exists in target ARB',
          ),
        );
      }
    }

    return errors;
  }

  /// Discovers all ARB files under lib/l10n and validates them.
  static Future<bool> runValidation({Directory? l10nDir}) async {
    final dir = l10nDir ?? Directory('lib/l10n');
    final templateFile = File('${dir.path}/app_en.arb');

    if (!await templateFile.exists()) {
      print(
        'Canonical translation file app_en.arb not found at ${templateFile.path}',
      );
      return false;
    }

    Map<String, dynamic> templateJson;
    try {
      templateJson =
          jsonDecode(await templateFile.readAsString()) as Map<String, dynamic>;
    } catch (e) {
      print('Malformed JSON in app_en.arb: $e');
      return false;
    }

    final arbRegex = RegExp(r'^app_([a-zA-Z_]+)\.arb$');
    final List<ValidationError> allErrors = [];

    await for (final entity in dir.list()) {
      if (entity is File) {
        final filename = entity.uri.pathSegments.last;
        final match = arbRegex.firstMatch(filename);
        if (match != null) {
          final locale = match.group(1)!;
          if (locale == 'en') continue; // Skip template

          Map<String, dynamic> targetJson;
          try {
            targetJson =
                jsonDecode(await entity.readAsString()) as Map<String, dynamic>;
          } catch (e) {
            allErrors.add(
              ValidationError(
                file: filename,
                locale: locale,
                key: 'N/A',
                errorType: 'MALFORMED_JSON',
                expected: 'Valid JSON ARB file',
                actual: 'JSON parsing failed: $e',
              ),
            );
            continue;
          }

          final errors = validateContent(
            filename: filename,
            locale: locale,
            templateJson: templateJson,
            targetJson: targetJson,
          );
          allErrors.addAll(errors);
        }
      }
    }

    if (allErrors.isNotEmpty) {
      print('=== ARB LOCALIZATION VALIDATION FAILED ===');
      for (final error in allErrors) {
        print(error);
      }
      print('Total errors: ${allErrors.length}');
      return false;
    }

    print('All ARB localization files are valid!');

    final quotesValid = await validateQuotes();
    return quotesValid;
  }

  static Future<bool> validateQuotes() async {
    final Directory quotesDir = Directory('assets/data/quotes');
    if (!await quotesDir.exists()) {
      print('Quotes directory not found at assets/data/quotes');
      return false;
    }

    final expectedThemes = ['Happy', 'Calm', 'Motivated', 'Relaxed', 'Reflective', 'Focused', 'Tired', 'Inspired'];
    final expectedTimes = ['Morning', 'Afternoon', 'Evening', 'Night'];
    final expectedLanguages = ['en', 'es', 'hi', 'fr', 'de'];

    bool success = true;

    for (final lang in expectedLanguages) {
      final langDir = Directory('${quotesDir.path}/$lang');
      if (!await langDir.exists()) {
        print('Quote language directory missing: ${langDir.path}');
        success = false;
        continue;
      }

      for (final theme in expectedThemes) {
        final file = File('${langDir.path}/${theme.toLowerCase()}.json');
        if (!await file.exists()) {
          print('Quote dataset missing: ${file.path}');
          success = false;
          continue;
        }

        try {
          final content = await file.readAsString();
          final Map<String, dynamic> data = jsonDecode(content) as Map<String, dynamic>;

          for (final time in expectedTimes) {
            if (!data.containsKey(time)) {
              print('Quote dataset ${file.path} is missing time range: $time');
              success = false;
              continue;
            }

            final timeData = data[time];
            if (timeData is! Map<String, dynamic>) {
              print('Quote dataset ${file.path} (Time: $time) data is not a Map');
              success = false;
              continue;
            }

            if (!timeData.containsKey('subtitle') || timeData['subtitle'].toString().trim().isEmpty) {
              print('Quote dataset ${file.path} (Time: $time) is missing or has empty subtitle');
              success = false;
            }

            if (!timeData.containsKey('quotes') || timeData['quotes'] is! List<dynamic>) {
              print('Quote dataset ${file.path} (Time: $time) is missing or has invalid quotes list');
              success = false;
              continue;
            }

            final quotes = timeData['quotes'] as List<dynamic>;
            if (quotes.length < 10) {
              print('Quote dataset ${file.path} (Time: $time) has only ${quotes.length} quotes (expected at least 10)');
              success = false;
            }

            final uniqueQuotes = quotes.map((q) => q.toString().trim()).toSet();
            if (uniqueQuotes.length != quotes.length) {
              print('Quote dataset ${file.path} (Time: $time) has duplicate quotes');
              success = false;
            }
            if (uniqueQuotes.any((q) => q.isEmpty)) {
              print('Quote dataset ${file.path} (Time: $time) has empty quotes');
              success = false;
            }
          }
        } catch (e) {
          print('Quote dataset ${file.path} failed to parse or validate: $e');
          success = false;
        }
      }
    }

    if (success) {
      print('All Quote localization files are valid!');
    }
    return success;
  }
}

void main() async {
  final success = await ArbValidator.runValidation();
  exit(success ? 0 : 1);
}
