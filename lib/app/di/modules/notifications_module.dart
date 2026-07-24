import 'package:get_it/get_it.dart';

import '../../../features/notifications/data/notifications_api_impl.dart';
import '../../../features/notifications/domain/notifications_api.dart';
import '../../../features/notifications/presentation/notifications_cubit.dart';

void registerNotificationsModule(GetIt getIt) {
  getIt
    ..registerLazySingleton<NotificationsApi>(NotificationsApiImpl.new)
    ..registerFactory<NotificationsCubit>(
      () => NotificationsCubit(getIt<NotificationsApi>()),
    );
}
