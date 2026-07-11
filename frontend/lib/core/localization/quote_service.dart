import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'locale_controller.dart';
import 'quote_model.dart';

// Provider that loads the localized quotes dataset for a specific theme, falling back to English/Happy on failure
final quoteDataProvider = FutureProvider.family<Map<String, dynamic>, String>((
  ref,
  theme,
) async {
  final locale = ref.watch(localeProvider);
  final langCode = locale.languageCode;
  final themeLower = theme.toLowerCase();

  try {
    final String jsonString = await rootBundle.loadString(
      'assets/data/quotes/$langCode/$themeLower.json',
    );
    return json.decode(jsonString) as Map<String, dynamic>;
  } catch (e) {
    // Robust fallback to English for the same theme
    try {
      final String jsonString = await rootBundle.loadString(
        'assets/data/quotes/en/$themeLower.json',
      );
      return json.decode(jsonString) as Map<String, dynamic>;
    } catch (_) {
      // Ultimate fallback to English Happy theme
      final String jsonString = await rootBundle.loadString(
        'assets/data/quotes/en/happy.json',
      );
      return json.decode(jsonString) as Map<String, dynamic>;
    }
  }
});

// A notifier to fetch the correct quote based on current theme, time of day, and rotation
class QuoteService {
  final Map<String, dynamic> _themeData;
  final String themeName;

  QuoteService(this._themeData, this.themeName);

  // Helper to determine time period based on hour
  String getTimePeriod(DateTime time) {
    final hour = time.hour;
    if (hour >= 5 && hour < 12) {
      return 'Morning';
    } else if (hour >= 12 && hour < 17) {
      return 'Afternoon';
    } else if (hour >= 17 && hour < 21) {
      return 'Evening';
    } else {
      return 'Night';
    }
  }

  QuoteModel getQuote(DateTime time) {
    final timePeriod = getTimePeriod(time);

    // Look up time category data (e.g. {"subtitle": "...", "quotes": [...]})
    final periodData = _themeData[timePeriod] as Map<String, dynamic>?;

    final String subtitleText =
        periodData?['subtitle']?.toString() ?? 'Inspiration for your journey';
    final quotesList = periodData?['quotes'] as List<dynamic>? ?? [];

    if (quotesList.isEmpty) {
      return QuoteModel(quote: "Keep moving forward.", subtitle: subtitleText);
    }

    // Determine deterministic quote index by day of the year (rotation logic)
    final int dayOfYear = time.difference(DateTime(time.year, 1, 1)).inDays;
    final int themeHash = themeName.toLowerCase().hashCode;
    final int index = (dayOfYear + themeHash).abs() % quotesList.length;
    final String quoteText = quotesList[index].toString();

    return QuoteModel(quote: quoteText, subtitle: subtitleText);
  }
}

// Provider for the QuoteService matching the active theme
final quoteServiceProvider = FutureProvider.family<QuoteService, String>((
  ref,
  theme,
) async {
  final themeData = await ref.watch(quoteDataProvider(theme).future);
  return QuoteService(themeData, theme);
});
