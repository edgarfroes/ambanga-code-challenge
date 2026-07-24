import '../interceptor_contract.dart';

/// Signals a specific HTTP status without performing UI side effects.
/// Session/navigation handling belongs to app-level listeners (DIP).
class HttpErrorInterceptor extends InterceptorContract {
  final int statusCode;
  final void Function(ResponseData response) onStatus;

  HttpErrorInterceptor(this.statusCode, {required this.onStatus});

  @override
  Future<BaseRequest> interceptRequest({required BaseRequest request}) async {
    return request;
  }

  @override
  Future<ResponseData> interceptResponse({
    required ResponseData response,
  }) async {
    if (response.statusCode == statusCode) {
      onStatus(response);
    }
    return response;
  }
}
