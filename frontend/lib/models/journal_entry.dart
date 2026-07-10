class JournalEntry {
  final String id;
  final String title;
  final String body;
  final DateTime createdAt;
  final String mood; // 'Great', 'Good', 'Okay', 'Sad'
  final String? aiInsight;

  const JournalEntry({
    required this.id,
    required this.title,
    required this.body,
    required this.createdAt,
    required this.mood,
    this.aiInsight,
  });

  JournalEntry copyWith({
    String? id,
    String? title,
    String? body,
    DateTime? createdAt,
    String? mood,
    String? aiInsight,
  }) {
    return JournalEntry(
      id: id ?? this.id,
      title: title ?? this.title,
      body: body ?? this.body,
      createdAt: createdAt ?? this.createdAt,
      mood: mood ?? this.mood,
      aiInsight: aiInsight ?? this.aiInsight,
    );
  }
}
