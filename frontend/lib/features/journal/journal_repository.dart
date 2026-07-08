import 'dart:async';
import '../../models/journal_entry.dart';

abstract class JournalRepository {
  List<JournalEntry> getEntries();
  Future<JournalEntry> addEntry(String title, String body, String mood);
  Future<String> generateAiInsight(String body);
}

class MockJournalRepository implements JournalRepository {
  final List<JournalEntry> _entries = [
    JournalEntry(
      id: 'journal-1',
      title: 'A Morning Walk in the Park',
      body:
          'The air was crisp and the golden leaves were falling. I felt a profound sense of connection with nature as I wandered along the paths. Taking time away from my desk made me realize how important offline breaks are for long-term sustainability.',
      createdAt: DateTime.now().subtract(const Duration(days: 1)),
      mood: 'Good', // Mapped to 'Good' mood icon
      aiInsight:
          'Your heart rate and mental clarity improve significantly during early outdoor activities. Schedule more walks.',
    ),
    JournalEntry(
      id: 'journal-2',
      title: 'Project Milestone Reached',
      body:
          'Finally finished the core architecture for the new project. It\'s been a long week of debugging and refactoring, but getting this built makes all the work worthwhile.',
      createdAt: DateTime.now().subtract(const Duration(days: 3)),
      mood: 'Great',
      aiInsight:
          'Completing big blocks of logic boosts your momentum. Break next milestones into similar chunks.',
    ),
    JournalEntry(
      id: 'journal-3',
      title: 'Coffee with an Old Friend',
      body:
          'We haven\'t talked in years. It was strange yet so familiar. We discussed our future plans and reminisced about old school days. Realized that strong social bonds really keep me grounded.',
      createdAt: DateTime.now().subtract(const Duration(days: 4)),
      mood: 'Okay',
      aiInsight:
          'Reconnecting with old connections provides emotional stability and reduces baseline stress levels.',
    ),
  ];

  @override
  List<JournalEntry> getEntries() {
    return List.from(_entries);
  }

  @override
  Future<JournalEntry> addEntry(String title, String body, String mood) async {
    await Future.delayed(
      const Duration(milliseconds: 1000),
    ); // Simulated network latency

    final insight = await generateAiInsight(body);

    final newEntry = JournalEntry(
      id: 'journal-${DateTime.now().millisecondsSinceEpoch}',
      title: title.isEmpty ? 'Untitled Entry' : title,
      body: body,
      createdAt: DateTime.now(),
      mood: mood,
      aiInsight: insight,
    );

    _entries.insert(0, newEntry); // Insert at top of list
    return newEntry;
  }

  @override
  Future<String> generateAiInsight(String body) async {
    await Future.delayed(const Duration(milliseconds: 800));
    final lower = body.toLowerCase();
    if (lower.contains('stress') ||
        lower.contains('tired') ||
        lower.contains('exhausted')) {
      return 'It seems you are feeling overwhelmed. Prioritize sleep and schedule a brief break to reset.';
    }
    if (lower.contains('happy') ||
        lower.contains('excited') ||
        lower.contains('great') ||
        lower.contains('accomplished')) {
      return 'You are in a positive state. Capitalize on this energy for creative tasks today.';
    }
    return 'Regular reflection keeps you aligned. Continue tracking your daily thoughts to notice weekly trends.';
  }
}
