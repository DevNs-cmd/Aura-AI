import 'package:flutter_test/flutter_test.dart';
import 'package:aura_ai/core/localization/quote_service.dart';

void main() {
  group('QuoteService Tests', () {
    test('getTimePeriod returns correct periods for hours', () {
      final mockData = {
        'Morning': {
          'subtitle': 'Start today with intent',
          'quotes': ['Morning Quote 1'],
        },
        'Afternoon': {
          'subtitle': 'Keep your momentum strong',
          'quotes': ['Afternoon Quote 1'],
        },
        'Evening': {
          'subtitle': 'Reflect and find comfort',
          'quotes': ['Evening Quote 1'],
        },
        'Night': {
          'subtitle': 'Rest and prepare for tomorrow',
          'quotes': ['Night Quote 1'],
        },
      };

      final service = QuoteService(mockData, 'Happy');

      // Morning: 05:00 AM – 11:59 AM
      expect(service.getTimePeriod(DateTime(2026, 7, 8, 5, 0)), 'Morning');
      expect(service.getTimePeriod(DateTime(2026, 7, 8, 11, 59)), 'Morning');

      // Afternoon: 12:00 PM – 04:59 PM
      expect(service.getTimePeriod(DateTime(2026, 7, 8, 12, 0)), 'Afternoon');
      expect(service.getTimePeriod(DateTime(2026, 7, 8, 16, 59)), 'Afternoon');

      // Evening: 05:00 PM – 08:59 PM
      expect(service.getTimePeriod(DateTime(2026, 7, 8, 17, 0)), 'Evening');
      expect(service.getTimePeriod(DateTime(2026, 7, 8, 20, 59)), 'Evening');

      // Night: 09:00 PM – 04:59 AM
      expect(service.getTimePeriod(DateTime(2026, 7, 8, 21, 0)), 'Night');
      expect(service.getTimePeriod(DateTime(2026, 7, 8, 4, 59)), 'Night');
    });

    test(
      'getQuote returns quote matching theme and rotating deterministically',
      () {
        final mockData = {
          'Morning': {
            'subtitle': 'Start today with intent',
            'quotes': List.generate(10, (i) => 'Happy Morning Quote $i'),
          },
          'Afternoon': {
            'subtitle': 'Keep your momentum strong',
            'quotes': ['Happy Afternoon Quote'],
          },
          'Evening': {
            'subtitle': 'Reflect and find comfort',
            'quotes': ['Happy Evening Quote'],
          },
          'Night': {
            'subtitle': 'Rest and prepare for tomorrow',
            'quotes': ['Happy Night Quote'],
          },
        };

        final service = QuoteService(mockData, 'Happy');

        // Select date with dayOfYear = 100
        // 2026-04-10 is day 100 of year 2026 (approx)
        final date1 = DateTime(2026, 4, 10, 8, 0); // 100th day approx
        final quote1 = service.getQuote(date1);

        final date2 = DateTime(
          2026,
          4,
          10,
          10,
          0,
        ); // same day, same time category
        final quote2 = service.getQuote(date2);

        // Quote should remain identical within same day same period
        expect(quote1.quote, quote2.quote);

        // Next day, same time category
        final date3 = DateTime(2026, 4, 11, 8, 0);
        final quote3 = service.getQuote(date3);

        // Quote should change/rotate on next day
        expect(quote1.quote != quote3.quote, true);
      },
    );

    test('QuoteService handles empty fallback correctly', () {
      final mockData = <String, dynamic>{};
      final service = QuoteService(mockData, 'Happy');
      final quote = service.getQuote(DateTime(2026, 7, 8, 8, 0));
      expect(quote.quote.isNotEmpty, true);
    });
  });
}
