import '../../core/network/api_client.dart';
import '../../models/notification_item.dart';

abstract class NotificationsRepository {
  Future<List<NotificationItem>> getNotifications();
  Future<void> markAsRead(String id);
  Future<void> markAllAsRead();
  Future<void> deleteNotification(String id);
}

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
  }
  @override Future<void> markAsRead(String id) async => _client.patch('/api/notifications/$id/read');
  @override Future<void> markAllAsRead() async => _client.patch('/api/notifications/read-all');
  @override Future<void> deleteNotification(String id) async =>
      throw UnsupportedError('The production notifications API only supports clearing all notifications.');
}
