import 'dart:async';

import 'package:flutter/material.dart';

import '../core/auth/auth_service.dart';
import 'di/locator.dart';
import 'home_shell.dart';
import 'router/app_router.dart';

class ChallengeApp extends StatefulWidget {
  const ChallengeApp({super.key});

  @override
  State<ChallengeApp> createState() => _ChallengeAppState();
}

class _ChallengeAppState extends State<ChallengeApp> {
  final _router = AppRouter();
  final _navigatorKey = GlobalKey<NavigatorState>();
  StreamSubscription<void>? _sessionSub;

  @override
  void initState() {
    super.initState();
    _sessionSub = locator<AuthService>().onSessionExpired.listen((_) {
      final navigator = _navigatorKey.currentState;
      if (navigator == null) return;
      navigator.pushNamedAndRemoveUntil(HomeShell.routeName, (_) => false);
      final messengerContext = _navigatorKey.currentContext;
      if (messengerContext == null || !messengerContext.mounted) return;
      ScaffoldMessenger.maybeOf(messengerContext)?.showSnackBar(
        const SnackBar(content: Text('Session expired. Please sign in again.')),
      );
    });
  }

  @override
  void dispose() {
    unawaited(_sessionSub?.cancel() ?? Future<void>.value());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Challenge App',
      navigatorKey: _navigatorKey,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
        useMaterial3: true,
      ),
      initialRoute: HomeShell.routeName,
      onGenerateRoute: _router.onGenerateRoute,
    );
  }
}
