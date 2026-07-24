import 'dart:async';

/// Minimal auth port used by session coordination (not full auth UI).
class AuthService {
  bool _isAuthenticated = true;
  final _sessionExpiredController = StreamController<void>.broadcast();

  bool get isAuthenticated => _isAuthenticated;

  Stream<void> get onSessionExpired => _sessionExpiredController.stream;

  void notifySessionExpired() {
    if (!_sessionExpiredController.isClosed) {
      _sessionExpiredController.add(null);
    }
  }

  Future<void> logout() async {
    _isAuthenticated = false;
  }

  Future<void> login() async {
    _isAuthenticated = true;
  }

  void dispose() {
    _sessionExpiredController.close();
  }
}
