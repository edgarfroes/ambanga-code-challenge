import '../domain/notification.dart';
import '../domain/notifications_api.dart';

/// In-memory / mock implementation so the app runs without a backend.
class NotificationsApiImpl implements NotificationsApi {
  NotificationsApiImpl({this.failTimes = 0});

  /// Number of consecutive failures before succeeding (for demo/testing).
  final int failTimes;
  int _attempts = 0;

  final List<Notification> _items = [
    Notification(
      id: 1,
      title: 'Welcome',
      body: 'Your challenge app is ready.',
      createdAt: DateTime.now().subtract(const Duration(minutes: 5)),
      isRead: false,
    ),
    Notification(
      id: 2,
      title: 'Polling active',
      body: 'Notifications refresh every 30 seconds while foregrounded.',
      createdAt: DateTime.now().subtract(const Duration(minutes: 2)),
      isRead: false,
    ),
  ];

  @override
  Future<List<Notification>> getUnreadNotifications() async {
    await Future<void>.delayed(const Duration(milliseconds: 400));
    _attempts++;
    if (_attempts <= failTimes) {
      throw Exception('Simulated notifications failure (#$_attempts)');
    }
    return List.unmodifiable(
      _items.where((n) => !n.isRead).toList(growable: false),
    );
  }

  @override
  Future<void> markAsRead(int notificationId) async {
    await Future<void>.delayed(const Duration(milliseconds: 200));
    final index = _items.indexWhere((n) => n.id == notificationId);
    if (index == -1) return;
    _items[index] = _items[index].copyWith(isRead: true);
  }
}
