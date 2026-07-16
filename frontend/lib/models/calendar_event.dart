import 'package:flutter/material.dart';

class CalendarEvent {
  final String id;
  final String title;
  final DateTime date; // Year, Month, Day only
  final String time;
  final IconData icon;
  final Color iconColor;
  final String category;
  final bool isCompleted;

  const CalendarEvent({
    required this.id,
    required this.title,
    required this.date,
    required this.time,
    required this.icon,
    required this.iconColor,
    required this.category,
    this.isCompleted = false,
  });

  CalendarEvent copyWith({
    String? id,
    String? title,
    DateTime? date,
    String? time,
    IconData? icon,
    Color? iconColor,
    String? category,
    bool? isCompleted,
  }) {
    return CalendarEvent(
      id: id ?? this.id,
      title: title ?? this.title,
      date: date ?? this.date,
      time: time ?? this.time,
      icon: icon ?? this.icon,
      iconColor: iconColor ?? this.iconColor,
      category: category ?? this.category,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }
}
