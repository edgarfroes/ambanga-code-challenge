import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../features/notifications/presentation/notifications_cubit.dart';
import '../../features/notifications/presentation/notifications_page.dart';
import '../../features/organisations/presentation/organisations_cubit.dart';
import '../../features/organisations/presentation/organisations_page.dart';
import '../../features/users/presentation/user_list_cubit.dart';
import '../../features/users/presentation/user_list_page.dart';
import '../di/locator.dart';
import '../home_shell.dart';

class AppRouter {
  Route<dynamic>? onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case HomeShell.routeName:
        return MaterialPageRoute<void>(
          builder: (_) => const HomeShell(),
          settings: settings,
        );
      case NotificationsPageRoute.name:
        return MaterialPageRoute<void>(
          builder: (_) => BlocProvider(
            create: (_) => locator<NotificationsCubit>(),
            child: const NotificationsPage(),
          ),
          settings: settings,
        );
      case OrganisationsPageRoute.name:
        return MaterialPageRoute<void>(
          builder: (_) => BlocProvider(
            create: (_) => locator<OrganisationsCubit>(),
            child: const OrganisationsPage(),
          ),
          settings: settings,
        );
      case UsersPageRoute.name:
        return MaterialPageRoute<void>(
          builder: (_) => BlocProvider(
            create: (_) => locator<UserListCubit>(),
            child: const UserListPage(),
          ),
          settings: settings,
        );
      default:
        return MaterialPageRoute<void>(
          builder: (_) => const HomeShell(),
          settings: settings,
        );
    }
  }
}

abstract final class NotificationsPageRoute {
  static const name = '/notifications';
}

abstract final class OrganisationsPageRoute {
  static const name = '/organisations';
}

abstract final class UsersPageRoute {
  static const name = '/users';
}
