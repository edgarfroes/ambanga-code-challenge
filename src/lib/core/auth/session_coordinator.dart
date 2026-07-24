import 'dart:async';

import 'auth_service.dart';

/// Ensures concurrent 401s only trigger logout once.
class SessionCoordinator {
  SessionCoordinator(this._authService);

  final AuthService _authService;
  bool _isHandlingUnauthorized = false;

  Future<void> handleUnauthorized() async {
    if (_isHandlingUnauthorized) return;
    _isHandlingUnauthorized = true;
    try {
      await _authService.logout();
      _authService.notifySessionExpired();
    } finally {
      _isHandlingUnauthorized = false;
    }
  }
}
