import 'package:get_it/get_it.dart';

import 'modules/core_module.dart';
import 'modules/notifications_module.dart';
import 'modules/organisations_module.dart';
import 'modules/users_module.dart';

final locator = GetIt.instance;

Future<void> setupLocator() async {
  await registerCoreModule(locator);
  registerNotificationsModule(locator);
  registerOrganisationsModule(locator);
  registerUsersModule(locator);
}
