import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/calendar_event.dart';

class CalendarState {
  final DateTime selectedDate;
  final DateTime displayedMonth;
  final Map<DateTime, List<CalendarEvent>> eventsByDate;

  CalendarState({
    required this.selectedDate,
    required this.displayedMonth,
    required this.eventsByDate,
  });

  CalendarState copyWith({
    DateTime? selectedDate,
    DateTime? displayedMonth,
    Map<DateTime, List<CalendarEvent>>? eventsByDate,
  }) {
    return CalendarState(
      selectedDate: selectedDate ?? this.selectedDate,
      displayedMonth: displayedMonth ?? this.displayedMonth,
      eventsByDate: eventsByDate ?? this.eventsByDate,
    );
  }
}

class CalendarNotifier extends StateNotifier<CalendarState> {
  CalendarNotifier() : super(_initialState());

  static CalendarState _initialState() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final displayedMonth = DateTime(now.year, now.month, 1);

    // Seed default mock events for today
    final defaultEvents = {
      today: [
        CalendarEvent(
          id: '1',
          title: 'Morning Mindfulness & Journaling',
          date: today,
          time: '08:00 AM',
          icon: Icons.edit_note_rounded,
          iconColor: const Color(0xFFFF9A3C),
          category: 'Journal',
          isCompleted: false,
        ),
        CalendarEvent(
          id: '2',
          title: 'Evening Run & Cardio',
          date: today,
          time: '07:00 PM',
          icon: Icons.directions_run_rounded,
          iconColor: const Color(0xFF5CB85C),
          category: 'Workout',
          isCompleted: true,
        ),
      ]
    };

    return CalendarState(
      selectedDate: today,
      displayedMonth: displayedMonth,
      eventsByDate: defaultEvents,
    );
  }

  void selectDate(DateTime date) {
    state = state.copyWith(selectedDate: DateTime(date.year, date.month, date.day));
  }

  void navigateMonth(int offsetMonths) {
    final displayed = state.displayedMonth;
    final nextMonth = DateTime(displayed.year, displayed.month + offsetMonths, 1);
    state = state.copyWith(displayedMonth: nextMonth);
  }

  void addEvent(CalendarEvent event) {
    final dateKey = DateTime(event.date.year, event.date.month, event.date.day);
    final currentEvents = Map<DateTime, List<CalendarEvent>>.from(state.eventsByDate);
    final dayList = List<CalendarEvent>.from(currentEvents[dateKey] ?? []);
    dayList.add(event);
    currentEvents[dateKey] = dayList;
    state = state.copyWith(eventsByDate: currentEvents);
  }

  void updateEvent(CalendarEvent updatedEvent) {
    final dateKey = DateTime(updatedEvent.date.year, updatedEvent.date.month, updatedEvent.date.day);
    final currentEvents = Map<DateTime, List<CalendarEvent>>.from(state.eventsByDate);

    // Also search other days in case the date changed
    DateTime? foundOldDateKey;
    for (final key in currentEvents.keys) {
      if (currentEvents[key]!.any((e) => e.id == updatedEvent.id)) {
        foundOldDateKey = key;
        break;
      }
    }

    if (foundOldDateKey != null) {
      final oldList = List<CalendarEvent>.from(currentEvents[foundOldDateKey]!);
      oldList.removeWhere((e) => e.id == updatedEvent.id);
      if (oldList.isEmpty) {
        currentEvents.remove(foundOldDateKey);
      } else {
        currentEvents[foundOldDateKey] = oldList;
      }
    }

    final newList = List<CalendarEvent>.from(currentEvents[dateKey] ?? []);
    newList.add(updatedEvent);
    currentEvents[dateKey] = newList;

    state = state.copyWith(eventsByDate: currentEvents);
  }

  void deleteEvent(String id) {
    final currentEvents = Map<DateTime, List<CalendarEvent>>.from(state.eventsByDate);
    DateTime? foundKey;
    for (final key in currentEvents.keys) {
      if (currentEvents[key]!.any((e) => e.id == id)) {
        foundKey = key;
        break;
      }
    }

    if (foundKey != null) {
      final updatedList = List<CalendarEvent>.from(currentEvents[foundKey]!);
      updatedList.removeWhere((e) => e.id == id);
      if (updatedList.isEmpty) {
        currentEvents.remove(foundKey);
      } else {
        currentEvents[foundKey] = updatedList;
      }
      state = state.copyWith(eventsByDate: currentEvents);
    }
  }

  void toggleComplete(String id) {
    final currentEvents = Map<DateTime, List<CalendarEvent>>.from(state.eventsByDate);
    DateTime? foundKey;
    CalendarEvent? foundEvent;

    for (final key in currentEvents.keys) {
      for (final event in currentEvents[key]!) {
        if (event.id == id) {
          foundKey = key;
          foundEvent = event;
          break;
        }
      }
      if (foundKey != null) break;
    }

    if (foundKey != null && foundEvent != null) {
      final updatedList = List<CalendarEvent>.from(currentEvents[foundKey]!);
      final index = updatedList.indexWhere((e) => e.id == id);
      if (index != -1) {
        updatedList[index] = foundEvent.copyWith(isCompleted: !foundEvent.isCompleted);
        currentEvents[foundKey] = updatedList;
        state = state.copyWith(eventsByDate: currentEvents);
      }
    }
  }
}

final calendarProvider = StateNotifierProvider<CalendarNotifier, CalendarState>((ref) {
  return CalendarNotifier();
});
