import 'package:bloc_test/bloc_test.dart';
import 'package:challenge_app/features/notifications/domain/notification.dart';
import 'package:challenge_app/features/notifications/domain/notifications_api.dart';
import 'package:challenge_app/features/notifications/presentation/notifications_cubit.dart';
import 'package:challenge_app/features/notifications/presentation/notifications_state.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _MockNotificationsApi extends Mock implements NotificationsApi {}

void main() {
  late _MockNotificationsApi api;

  final sample = [
    Notification(
      id: 1,
      title: 'A',
      body: 'B',
      createdAt: DateTime(2026),
      isRead: false,
    ),
  ];

  setUp(() {
    api = _MockNotificationsApi();
  });

  blocTest<NotificationsCubit, NotificationsState>(
    'emits loaded notifications on successful start',
    build: () {
      when(() => api.getUnreadNotifications()).thenAnswer((_) async => sample);
      return NotificationsCubit(api);
    },
    act: (cubit) => cubit.start(),
    wait: const Duration(milliseconds: 50),
    expect: () => [
      isA<NotificationsLoaded>().having(
        (s) => s.notifications,
        'notifications',
        sample,
      ),
    ],
  );
}
