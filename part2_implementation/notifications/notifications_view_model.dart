import 'notification.dart';

/// State hierarchy for [NotificationsCubit].
///
/// - [NotificationsLoading]: initial load in progress.
/// - [NotificationsLoaded]: data available.
/// - [NotificationsError]: polling stopped after 3 consecutive failed cycles;
///   carries [previousNotifications] so the UI can keep showing stale data
///   under the error banner.
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
