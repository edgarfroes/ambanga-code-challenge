import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import 'notification.dart';
import 'notifications_api.dart';
import 'notifications_view_model.dart';

/// Polls [NotificationsApi] every 30 seconds while the app is foregrounded.
///
/// - Each cycle retries failures with exponential backoff (1s, 2s, 4s,
///   maximum 3 retries per cycle).
/// - A cycle that still fails after all retries counts as 1 failed cycle.
/// - After 3 consecutive failed cycles polling stops and an error state is
///   emitted so the UI can show a banner.
/// - Polling resumes automatically when the app returns to the foreground.
class NotificationsCubit extends Cubit<NotificationsState> {
  NotificationsCubit(this._api) : super(const NotificationsLoading());

  static const _pollInterval = Duration(seconds: 30);
  static const _maxRetriesPerCycle = 3;
  static const _maxFailedCycles = 3;
  static const _backoffSeconds = [1, 2, 4];

  final NotificationsApi _api;

  Timer? _pollTimer;
  bool _isInForeground = true;
  bool _isPolling = false;
  int _consecutiveFailedCycles = 0;

  /// Starts polling. Safe to call again to restart after an error.
  void start() {
    _isInForeground = true;
    _consecutiveFailedCycles = 0;
    unawaited(_runCycle());
    _scheduleNextPoll();
  }

  /// App returned to the foreground: reset failures and resume polling.
  void onAppResumed() {
    if (_isInForeground) return;
    _isInForeground = true;
    _consecutiveFailedCycles = 0;
    if (state is NotificationsError) {
      emit(const NotificationsLoading());
    }
    unawaited(_runCycle());
    _scheduleNextPoll();
  }

  /// App went to the background: stop polling.
  void onAppPaused() {
    _isInForeground = false;
    _pollTimer?.cancel();
    _pollTimer = null;
  }

  Future<void> markAsRead(int id) async {
    await _api.markAsRead(id);
    if (isClosed) return;
    unawaited(_runCycle());
  }

  Future<void> _runCycle() async {
    if (!_isInForeground || _isPolling || isClosed) return;

    _isPolling = true;
    try {
      final notifications = await _fetchWithRetries();
      if (isClosed) return;

      _consecutiveFailedCycles = 0;
      emit(NotificationsLoaded(notifications));
      _scheduleNextPoll();
    } catch (_) {
      if (isClosed) return;

      _consecutiveFailedCycles++;
      if (_consecutiveFailedCycles >= _maxFailedCycles) {
        _pollTimer?.cancel();
        _pollTimer = null;
        final previous = switch (state) {
          NotificationsLoaded(:final notifications) => notifications,
          NotificationsError(:final previousNotifications) =>
            previousNotifications,
          _ => null,
        };
        emit(
          NotificationsError(
            'Unable to load notifications after $_maxFailedCycles failed attempts.',
            previousNotifications: previous,
          ),
        );
      } else {
        _scheduleNextPoll();
      }
    } finally {
      _isPolling = false;
    }
  }

  /// One fetch attempt plus up to [_maxRetriesPerCycle] retries with
  /// exponential backoff (1s, 2s, 4s).
  Future<List<Notification>> _fetchWithRetries() async {
    Object? lastError;

    for (var attempt = 0; attempt <= _maxRetriesPerCycle; attempt++) {
      if (!_isInForeground || isClosed) {
        throw StateError('Polling interrupted');
      }

      try {
        return await _api.getUnreadNotifications();
      } catch (error) {
        lastError = error;
        if (attempt == _maxRetriesPerCycle) break;
        await Future<void>.delayed(
          Duration(seconds: _backoffSeconds[attempt]),
        );
      }
    }

    throw lastError ?? Exception('Unknown notifications fetch error');
  }

  void _scheduleNextPoll() {
    _pollTimer?.cancel();
    if (!_isInForeground || isClosed) return;
    if (_consecutiveFailedCycles >= _maxFailedCycles) return;

    _pollTimer = Timer(_pollInterval, () {
      unawaited(_runCycle());
    });
  }

  @override
  Future<void> close() {
    _pollTimer?.cancel();
    _pollTimer = null;
    return super.close();
  }
}
