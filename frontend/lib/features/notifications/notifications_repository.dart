<<<<<<< HEAD
=======
import 'dart:async';
import 'package:dio/dio.dart';
>>>>>>> 8a877bf27f7220ade008db9a02914e1cdcb22120
import '../../core/network/api_client.dart';
import '../../models/notification_item.dart';

abstract class NotificationsRepository {
  Future<List<NotificationItem>> getNotifications();
  Future<void> markAsRead(String id);
  Future<void> markAllAsRead();
  Future<void> deleteNotification(String id);
}

<<<<<<< HEAD
class ApiNotificationsRepository implements NotificationsRepository {
  ApiNotificationsRepository(this._client);
  final ApiClient _client;
  NotificationItem _fromJson(Map<String, dynamic> json) => NotificationItem(
    id: json['id'] as String, title: json['title'] as String, body: json['message'] as String,
    timestamp: DateTime.parse(json['createdAt'] as String), category: json['type'] as String,
    priority: json['type'] == 'warning' ? 'high' : 'medium', isRead: json['read'] as bool? ?? false,
  );
  @override Future<List<NotificationItem>> getNotifications() async {
    final response = await _client.get<List<dynamic>>('/api/notifications');
    return response.data!.map((e) => _fromJson(Map<String, dynamic>.from(e as Map))).toList();
=======
class HttpNotificationsRepository implements NotificationsRepository {
  HttpNotificationsRepository({Dio? dio}) : _dio = dio ?? ApiClient().dio;

  final Dio _dio;

  @override
  Future<List<NotificationItem>> getNotifications() async {
    final response = await _dio.get<dynamic>('/notifications');
    if (response.data is! List) {
      throw const FormatException('Unexpected notifications response shape.');
    }
    return (response.data as List)
        .whereType<Map<String, dynamic>>()
        .map(_fromApi)
        .toList(growable: false);
  }

  @override
  Future<void> markAsRead(String id) async {
    await _dio.patch<dynamic>('/notifications/$id/read');
  }

  @override
  Future<void> markAllAsRead() async {
    await _dio.patch<dynamic>('/notifications/read-all');
  }

  @override
  Future<void> deleteNotification(String id) async {
    await _dio.delete<dynamic>('/notifications/$id');
  }

  NotificationItem _fromApi(Map<String, dynamic> value) {
    final type = value['type']?.toString() ?? 'info';
    return NotificationItem(
      id: value['id']?.toString() ?? '',
      title: value['title']?.toString() ?? '',
      body: value['message']?.toString() ?? '',
      timestamp: DateTime.tryParse(value['createdAt']?.toString() ?? '') ?? DateTime.now(),
      category: type,
      priority: switch (type) {
        'warning' => 'high',
        'success' => 'medium',
        _ => 'low',
      },
      isRead: value['read'] == true,
    );
  }
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
  Future<List<NotificationItem>> getNotifications() async {
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
>>>>>>> 8a877bf27f7220ade008db9a02914e1cdcb22120
  }
  @override Future<void> markAsRead(String id) async => _client.patch('/api/notifications/$id/read');
  @override Future<void> markAllAsRead() async => _client.patch('/api/notifications/read-all');
  @override Future<void> deleteNotification(String id) async =>
      throw UnsupportedError('The production notifications API only supports clearing all notifications.');
}
