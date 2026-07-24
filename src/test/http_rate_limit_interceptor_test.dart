import 'package:challenge_app/core/network/interceptor_contract.dart';
import 'package:challenge_app/core/network/interceptors/http_rate_limit_interceptor.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('resends after Retry-After and returns success', () async {
    var calls = 0;
    final interceptor = HttpRateLimitInterceptor(
      executeRequest: (request) async {
        calls++;
        return const ResponseData(statusCode: 200, headers: {}, body: 'ok');
      },
    );

    const request = BaseRequest(url: 'https://example.com', method: 'GET');
    await interceptor.interceptRequest(request: request);

    final first = await interceptor.interceptResponse(
      response: const ResponseData(
        statusCode: 429,
        headers: {'Retry-After': '0'},
      ),
    );

    expect(first.statusCode, 200);
    expect(calls, 1);
  });

  test('throws after more than 2 resends', () async {
    final interceptor = HttpRateLimitInterceptor(
      executeRequest: (_) async => const ResponseData(
        statusCode: 429,
        headers: {'Retry-After': '0'},
      ),
    );

    await interceptor.interceptRequest(
      request: const BaseRequest(url: 'https://example.com', method: 'GET'),
    );

    expect(
      () => interceptor.interceptResponse(
        response: const ResponseData(
          statusCode: 429,
          headers: {'Retry-After': '0'},
        ),
      ),
      throwsA(isA<RateLimitExceededException>()),
    );
  });
}
