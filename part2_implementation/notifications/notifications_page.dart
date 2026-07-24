import 'package:flutter/material.dart' hide Notification;
import 'package:flutter_bloc/flutter_bloc.dart';

import 'notification.dart';
import 'notifications_cubit.dart';
import 'notifications_view_model.dart';

/// Notifications screen. Reacts to app lifecycle to start/stop polling and
/// renders state via [BlocBuilder]: loading spinner, list, or error banner.
class NotificationsPage extends StatefulWidget {
  const NotificationsPage({super.key});

  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    context.read<NotificationsCubit>().start();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final cubit = context.read<NotificationsCubit>();
    switch (state) {
      case AppLifecycleState.resumed:
        cubit.onAppResumed();
      case AppLifecycleState.inactive:
      case AppLifecycleState.paused:
      case AppLifecycleState.detached:
      case AppLifecycleState.hidden:
        cubit.onAppPaused();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Notifications')),
      body: BlocBuilder<NotificationsCubit, NotificationsState>(
        builder: (context, state) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (state is NotificationsError)
                MaterialBanner(
                  content: Text(state.message),
                  actions: [
                    TextButton(
                      onPressed: () =>
                          context.read<NotificationsCubit>().onAppResumed(),
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              Expanded(child: _buildBody(context, state)),
            ],
          );
        },
      ),
    );
  }

  Widget _buildBody(BuildContext context, NotificationsState state) {
    return switch (state) {
      NotificationsLoading() => const Center(
          child: CircularProgressIndicator(),
        ),
      NotificationsLoaded(:final notifications) => _NotificationsList(
          notifications: notifications,
        ),
      NotificationsError(:final previousNotifications) =>
        previousNotifications == null || previousNotifications.isEmpty
            ? const Center(child: Text('No notifications available.'))
            : _NotificationsList(notifications: previousNotifications),
    };
  }
}

class _NotificationsList extends StatelessWidget {
  const _NotificationsList({required this.notifications});

  final List<Notification> notifications;

  @override
  Widget build(BuildContext context) {
    if (notifications.isEmpty) {
      return const Center(child: Text('No unread notifications.'));
    }

    return ListView.separated(
      itemCount: notifications.length,
      separatorBuilder: (_, _) => const Divider(height: 1),
      itemBuilder: (context, index) {
        final notification = notifications[index];
        return ListTile(
          title: Text(notification.title),
          subtitle: Text(notification.body),
          trailing: IconButton(
            icon: const Icon(Icons.done),
            onPressed: () =>
                context.read<NotificationsCubit>().markAsRead(notification.id),
          ),
        );
      },
    );
  }
}
