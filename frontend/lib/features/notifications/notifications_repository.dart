import 'dart:async';
import '../../models/notification_item.dart';

abstract class NotificationsRepository {
  List<NotificationItem> getNotifications();
  Future<void> markAsRead(String id);
  Future<void> markAllAsRead();
  Future<void> deleteNotification(String id);
}

class MockNotificationsRepository implements NotificationsRepository {
  final List<NotificationItem> _notifications = [
    NotificationItem(
      id: 'notif-1',
      title: 'Daily Reflection Time',
      body:
          'Take 2 minutes to log your reflections. Writing helps reduce baseline stress.',
      timestamp: DateTime.now().subtract(const Duration(hours: 2)),
      category: 'Journal',
      priority: 'medium',
      isRead: false,
    ),
    NotificationItem(
      id: 'notif-2',
      title: 'Goal Milestone Alert',
      body:
          'Keep the momentum going! Only 5 sessions left to achieve your Morning Yoga Routine target.',
      timestamp: DateTime.now().subtract(const Duration(hours: 5)),
      category: 'Goals',
      priority: 'high',
      isRead: false,
    ),
    NotificationItem(
      id: 'notif-3',
      title: 'Aura Analytics Insight',
      body:
          'We noticed you log your highest focus scores on Tuesday mornings. Plan next week accordingly.',
      timestamp: DateTime.now().subtract(const Duration(days: 1)),
      category: 'AI Suggestions',
      priority: 'low',
      isRead: true,
    ),
  ];

  @override
  List<NotificationItem> getNotifications() {
    return List.from(_notifications);
  }

  @override
  Future<void> markAsRead(String id) async {
    await Future.delayed(const Duration(milliseconds: 100));
    final idx = _notifications.indexWhere((n) => n.id == id);
    if (idx != -1) {
      _notifications[idx] = _notifications[idx].copyWith(isRead: true);
    }
  }

  @override
  Future<void> markAllAsRead() async {
    await Future.delayed(const Duration(milliseconds: 200));
    for (int i = 0; i < _notifications.length; i++) {
      _notifications[i] = _notifications[i].copyWith(isRead: true);
    }
  }

  @override
  Future<void> deleteNotification(String id) async {
    await Future.delayed(const Duration(milliseconds: 200));
    _notifications.removeWhere((n) => n.id == id);
  }
}
