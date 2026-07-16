import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/network/api_config.dart';
import '../../models/notification_item.dart';
import 'notifications_repository.dart';

class NotificationsState {
  final List<NotificationItem> notifications;
  final bool isLoading;

  NotificationsState({required this.notifications, this.isLoading = false});

  NotificationsState copyWith({
    List<NotificationItem>? notifications,
    bool? isLoading,
  }) {
    return NotificationsState(
      notifications: notifications ?? this.notifications,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

final notificationsRepositoryProvider = Provider<NotificationsRepository>((ref) {
  return ApiConfig.useMockRepositories
      ? MockNotificationsRepository()
      : HttpNotificationsRepository();
});

class NotificationsNotifier extends StateNotifier<NotificationsState> {
  final NotificationsRepository _repository;

  NotificationsNotifier(this._repository) : super(NotificationsState(notifications: [])) {
    _loadNotifications();
  }

  Future<void> _loadNotifications() async {
    state = state.copyWith(isLoading: true);
    try {
      final notifications = await _repository.getNotifications();
      if (mounted) state = state.copyWith(notifications: notifications, isLoading: false);
    } catch (_) {
      if (mounted) state = state.copyWith(isLoading: false);
    }
  }

  Future<void> readNotification(String id) async {
    try {
      await _repository.markAsRead(id);
      state = state.copyWith(
        notifications: state.notifications
            .map((n) => n.id == id ? n.copyWith(isRead: true) : n)
            .toList(),
      );
    } catch (_) {}
  }

  Future<void> readAll() async {
    try {
      await _repository.markAllAsRead();
      state = state.copyWith(
        notifications: state.notifications
            .map((n) => n.copyWith(isRead: true))
            .toList(),
      );
    } catch (_) {}
  }

  Future<void> dismiss(String id) async {
    state = state.copyWith(isLoading: true);
    try {
      await _repository.deleteNotification(id);
      state = state.copyWith(
        notifications: state.notifications.where((n) => n.id != id).toList(),
        isLoading: false,
      );
    } catch (_) {
      state = state.copyWith(isLoading: false);
    }
  }
}

final notificationsProvider =
    StateNotifierProvider<NotificationsNotifier, NotificationsState>((ref) {
      final repository = ref.watch(notificationsRepositoryProvider);
      return NotificationsNotifier(repository);
    });

class _UnavailableNotificationsRepository implements NotificationsRepository {
  Never _unavailable() => throw StateError('The API client is not configured.');
  @override Future<void> deleteNotification(String id) async => _unavailable();
  @override Future<List<NotificationItem>> getNotifications() async => _unavailable();
  @override Future<void> markAllAsRead() async => _unavailable();
  @override Future<void> markAsRead(String id) async => _unavailable();
}
