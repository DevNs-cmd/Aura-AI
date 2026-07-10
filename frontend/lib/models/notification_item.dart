class NotificationItem {
  final String id;
  final String title;
  final String body;
  final DateTime timestamp;
  final String category; // 'Journal', 'Goals', 'AI Suggestions'
  final String priority; // 'high', 'medium', 'low'
  final bool isRead;

  const NotificationItem({
    required this.id,
    required this.title,
    required this.body,
    required this.timestamp,
    required this.category,
    required this.priority,
    this.isRead = false,
  });

  NotificationItem copyWith({
    String? id,
    String? title,
    String? body,
    DateTime? timestamp,
    String? category,
    String? priority,
    bool? isRead,
  }) {
    return NotificationItem(
      id: id ?? this.id,
      title: title ?? this.title,
      body: body ?? this.body,
      timestamp: timestamp ?? this.timestamp,
      category: category ?? this.category,
      priority: priority ?? this.priority,
      isRead: isRead ?? this.isRead,
    );
  }
}
