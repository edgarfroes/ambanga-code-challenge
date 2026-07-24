import 'package:get_it/get_it.dart';

import '../../../features/organisations/data/organisations_api_impl.dart';
import '../../../features/organisations/domain/organisation_service.dart';
import '../../../features/organisations/domain/organisations_api.dart';
import '../../../features/organisations/presentation/organisations_cubit.dart';

void registerOrganisationsModule(GetIt getIt) {
  getIt
    ..registerLazySingleton<OrganisationsApi>(OrganisationsApiImpl.new)
    ..registerLazySingleton<OrganisationService>(
      () => OrganisationService(getIt<OrganisationsApi>()),
    )
    ..registerFactory<OrganisationsCubit>(
      () => OrganisationsCubit(getIt<OrganisationService>()),
    );
}
