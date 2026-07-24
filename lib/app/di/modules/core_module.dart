import 'package:get_it/get_it.dart';

import '../../../core/auth/auth_service.dart';
import '../../../core/auth/session_coordinator.dart';
import '../../../core/network/interceptors/http_error_interceptor.dart';
import '../../../core/network/interceptors/http_rate_limit_interceptor.dart';
import '../../../core/network/remote_api_client.dart';

Future<void> registerCoreModule(GetIt getIt) async {
  getIt
    ..registerLazySingleton<AuthService>(AuthService.new)
    ..registerLazySingleton<SessionCoordinator>(
      () => SessionCoordinator(getIt<AuthService>()),
    )
    ..registerLazySingleton<RemoteApiClient>(() {
      late final RemoteApiClient client;
      client = RemoteApiClient(
        baseUrl: 'https://api.example.com',
        interceptors: [
          HttpRateLimitInterceptor(
            executeRequest: (request) => client.send(request),
          ),
          HttpErrorInterceptor(
            401,
            onStatus: (_) {
              getIt<SessionCoordinator>().handleUnauthorized();
            },
          ),
        ],
      );
      return client;
    });
}
