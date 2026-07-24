import '../domain/notification.dart';

sealed class NotificationsState {
  const NotificationsState();
}

class NotificationsLoading extends NotificationsState {
  const NotificationsLoading();
}

class NotificationsLoaded extends NotificationsState {
  final List<Notification> notifications;

  const NotificationsLoaded(this.notifications);
}

class NotificationsError extends NotificationsState {
  final String message;
  final List<Notification>? previousNotifications;

  const NotificationsError(
    this.message, {
    this.previousNotifications,
  });
}
