import '../interceptor_contract.dart';

class RateLimitExceededException implements Exception {
  final String message;
  const RateLimitExceededException(this.message);

  @override
  String toString() => 'RateLimitExceededException: $message';
}

class HttpRateLimitInterceptor extends InterceptorContract {
  /// Executes the HTTP request. Inject this function to allow testing
  /// without depending on a real HTTP client.
  final Future<ResponseData> Function(BaseRequest request) executeRequest;

  static const _maxResends = 2;
  static const _retryAfterHeader = 'Retry-After';

  BaseRequest? _currentRequest;
  int _resendCount = 0;
  bool _isResending = false;

  HttpRateLimitInterceptor({required this.executeRequest});

  @override
  Future<BaseRequest> interceptRequest({required BaseRequest request}) async {
    if (!_isResending) {
      _currentRequest = request;
      _resendCount = 0;
    }
    return request;
  }

  @override
  Future<ResponseData> interceptResponse({
    required ResponseData response,
  }) async {
    if (response.statusCode != 429) {
      return response;
    }

    if (_isResending) {
      return response;
    }

    return _handleRateLimit(response);
  }

  Future<ResponseData> _handleRateLimit(ResponseData response) async {
    final request = _currentRequest;
    if (request == null) {
      throw const RateLimitExceededException(
        'Received 429 but no original request is available to resend.',
      );
    }

    var current = response;

    while (current.statusCode == 429) {
      if (_resendCount >= _maxResends) {
        throw const RateLimitExceededException(
          'Rate limit exceeded: maximum of 2 automatic resends reached.',
        );
      }

      final retryAfterSeconds = _readRetryAfterSeconds(current.headers);
      await Future<void>.delayed(Duration(seconds: retryAfterSeconds));

      _resendCount++;
      _isResending = true;
      try {
        current = await executeRequest(request);
      } finally {
        _isResending = false;
      }
    }

    return current;
  }

  int _readRetryAfterSeconds(Map<String, String> headers) {
    final normalized = <String, String>{
      for (final entry in headers.entries) entry.key.toLowerCase(): entry.value,
    };
    final raw = normalized[_retryAfterHeader.toLowerCase()];
    final seconds = int.tryParse(raw ?? '');
    if (seconds == null || seconds < 0) {
      return 0;
    }
    return seconds;
  }
}
