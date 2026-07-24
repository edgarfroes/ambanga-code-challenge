import 'dart:convert';

import 'package:http/http.dart' as http;

import 'interceptor_contract.dart';

class RemoteApiException implements Exception {
  final int statusCode;
  final String message;

  const RemoteApiException(this.statusCode, this.message);

  @override
  String toString() => 'RemoteApiException($statusCode): $message';
}

class RemoteApiClient {
  RemoteApiClient({
    required this.baseUrl,
    http.Client? httpClient,
    List<InterceptorContract>? interceptors,
  })  : _httpClient = httpClient ?? http.Client(),
        _interceptors = List.unmodifiable(interceptors ?? const []);

  final String baseUrl;
  final http.Client _httpClient;
  final List<InterceptorContract> _interceptors;

  Future<ResponseData> get(
    String path, {
    Map<String, String>? headers,
  }) {
    return send(
      BaseRequest(
        url: _resolve(path),
        method: 'GET',
        headers: headers ?? const {},
      ),
    );
  }

  Future<ResponseData> post(
    String path, {
    Map<String, String>? headers,
    Object? body,
  }) {
    return send(
      BaseRequest(
        url: _resolve(path),
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
          ...?headers,
        },
        body: body,
      ),
    );
  }

  Future<ResponseData> delete(
    String path, {
    Map<String, String>? headers,
  }) {
    return send(
      BaseRequest(
        url: _resolve(path),
        method: 'DELETE',
        headers: headers ?? const {},
      ),
    );
  }

  Future<ResponseData> send(BaseRequest request) async {
    var current = request;
    for (final interceptor in _interceptors) {
      current = await interceptor.interceptRequest(request: current);
    }

    var response = await _execute(current);

    for (final interceptor in _interceptors) {
      response = await interceptor.interceptResponse(response: response);
    }

    return response;
  }

  Future<ResponseData> _execute(BaseRequest request) async {
    final uri = Uri.parse(request.url);
    final headers = request.headers;
    final encodedBody = switch (request.body) {
      null => null,
      final String value => value,
      final Object value => jsonEncode(value),
    };

    final http.Response raw = switch (request.method.toUpperCase()) {
      'GET' => await _httpClient.get(uri, headers: headers),
      'POST' => await _httpClient.post(uri, headers: headers, body: encodedBody),
      'DELETE' => await _httpClient.delete(uri, headers: headers),
      'PUT' => await _httpClient.put(uri, headers: headers, body: encodedBody),
      'PATCH' =>
        await _httpClient.patch(uri, headers: headers, body: encodedBody),
      final method => throw UnsupportedError('Unsupported method: $method'),
    };

    dynamic body = raw.body;
    if (raw.body.isNotEmpty) {
      try {
        body = jsonDecode(raw.body);
      } catch (_) {
        body = raw.body;
      }
    }

    return ResponseData(
      statusCode: raw.statusCode,
      headers: raw.headers,
      body: body,
    );
  }

  String _resolve(String path) {
    if (path.startsWith('http://') || path.startsWith('https://')) {
      return path;
    }
    final normalizedBase =
        baseUrl.endsWith('/') ? baseUrl.substring(0, baseUrl.length - 1) : baseUrl;
    final normalizedPath = path.startsWith('/') ? path : '/$path';
    return '$normalizedBase$normalizedPath';
  }

  void close() => _httpClient.close();
}
