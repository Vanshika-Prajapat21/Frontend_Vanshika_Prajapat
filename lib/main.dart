import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'constants.dart';
import 'logic/app_logic.dart';
import 'screens/alert_detail_screen.dart';
import 'screens/alerts_screen.dart';
import 'screens/dashboard_screen.dart';
import 'widgets/app_shell.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (_) => AppLogic()..loadAlertsData(),
      child: const MyApp(),
    ),
  );
}

final _router = GoRouter(
  initialLocation: '/',
  routes: [
    ShellRoute(
      builder: (context, state, child) {
        final location = state.matchedLocation;
        final activeRoute = location == '/' ? 'dashboard' : 'alerts';
        return AppShell(
          activeRoute: activeRoute,
          onSelectDashboard: () => context.go('/'),
          onSelectAlerts: () => context.go('/alerts'),
          child: child,
        );
      },
      routes: [
        GoRoute(
          path: '/',
          builder: (context, state) => const DashboardScreen(),
        ),
        GoRoute(
          path: '/alerts',
          builder: (context, state) => const AlertsScreen(),
        ),
        GoRoute(
          path: '/alerts/:id',
          builder: (context, state) {
            final logic = context.read<AppLogic>();
            final id = state.pathParameters['id']!;
            if (logic.alerts.isEmpty) {
              return const AlertsScreen();
            }
            final alert = logic.alerts.firstWhere(
              (a) => a.id == id,
              orElse: () => logic.alerts.first,
            );
            return AlertDetailScreen(alert: alert);
          },
        ),
      ],
    ),
  ],
);

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Security Alerts Dashboard',
      debugShowCheckedModeBanner: false,
      routerConfig: _router,
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: AppColors.background,
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.buttonDark,
          primary: AppColors.buttonDark,
          surface: AppColors.cardBg,
        ),
      ),
    );
  }
}
