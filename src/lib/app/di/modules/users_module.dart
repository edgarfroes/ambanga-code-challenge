import 'package:get_it/get_it.dart';

import '../../../features/users/data/user_service_impl.dart';
import '../../../features/users/domain/user_service.dart';
import '../../../features/users/presentation/user_list_cubit.dart';

void registerUsersModule(GetIt getIt) {
  getIt
    ..registerLazySingleton<UserService>(UserServiceImpl.new)
    ..registerFactory<UserListCubit>(
      () => UserListCubit(getIt<UserService>()),
    );
}
