enum MemoryCategory { personal, work, insight, fact }

class Memory {
  final String id;
  final String title;
  final String description;
  final DateTime storedAt;
  final MemoryCategory category;
  final String importance; // 'high', 'medium', 'low'
  final bool isPinned;

  const Memory({
    required this.id,
    required this.title,
    required this.description,
    required this.storedAt,
    required this.category,
    this.importance = 'medium',
    this.isPinned = false,
  });

  Memory copyWith({
    String? id,
    String? title,
    String? description,
    DateTime? storedAt,
    MemoryCategory? category,
    String? importance,
    bool? isPinned,
  }) {
    return Memory(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      storedAt: storedAt ?? this.storedAt,
      category: category ?? this.category,
      importance: importance ?? this.importance,
      isPinned: isPinned ?? this.isPinned,
    );
  }
}
