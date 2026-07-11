class Goal {
  final String id;
  final String title;
  final String category; // 'Health', 'Learning', 'Work', etc.
  final double progress; // Range 0.0 to 1.0
  final String statusText; // '15 of 20 sessions', '8 of 20 modules', etc.
  final String deadline; // 'Oct 30', 'Nov 12', etc.
  final bool isCompleted;

  const Goal({
    required this.id,
    required this.title,
    required this.category,
    required this.progress,
    required this.statusText,
    required this.deadline,
    this.isCompleted = false,
  });

  Goal copyWith({
    String? id,
    String? title,
    String? category,
    double? progress,
    String? statusText,
    String? deadline,
    bool? isCompleted,
  }) {
    return Goal(
      id: id ?? this.id,
      title: title ?? this.title,
      category: category ?? this.category,
      progress: progress ?? this.progress,
      statusText: statusText ?? this.statusText,
      deadline: deadline ?? this.deadline,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }
}
