import 'package:flutter/material.dart';

import 'router/app_router.dart';

class HomeShell extends StatelessWidget {
  const HomeShell({super.key});

  static const routeName = '/';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Challenge App')),
      body: ListView(
        children: [
          ListTile(
            leading: const Icon(Icons.notifications_outlined),
            title: const Text('Notifications'),
            subtitle: const Text('Polling cubit · exponential backoff'),
            onTap: () =>
                Navigator.of(context).pushNamed(NotificationsPageRoute.name),
          ),
          ListTile(
            leading: const Icon(Icons.business_outlined),
            title: const Text('Organisations'),
            subtitle: const Text('Service → Cubit (fixed boundary)'),
            onTap: () =>
                Navigator.of(context).pushNamed(OrganisationsPageRoute.name),
          ),
          ListTile(
            leading: const Icon(Icons.people_outline),
            title: const Text('Users'),
            subtitle: const Text('Fixed UserListCubit from Part 1'),
            onTap: () => Navigator.of(context).pushNamed(UsersPageRoute.name),
          ),
        ],
      ),
    );
  }
}
