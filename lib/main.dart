import 'package:fitmomentum/features/charts/charts_page.dart';
import 'package:fitmomentum/features/dashboard/dashboard_page.dart';
import 'package:fitmomentum/features/goals/goals_page.dart';
import 'package:fitmomentum/features/settings/settings_page.dart';
import 'package:fitmomentum/shared/db/app_database.dart';
import 'package:fitmomentum/shared/repo/metrics_repository.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'features/profile/view/profile_onboarding_page.dart';
import 'package:provider/provider.dart';
import 'package:fitmomentum/shared/sync/sync_bootstrap.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final db = await AppDatabase.open();
  final repo = MetricsRepository(db);

  final sync = SyncBootstrap.ensure(
    db: db,
    repo: repo,
    platform: defaultTargetPlatform == TargetPlatform.iOS ? 'ios' : 'android',
  );
  await sync.init();

  runApp(
    Provider<MetricsRepository>.value(
      value: repo,
      child: const FitMomentumApp(),
    ),
  );
}

class FitMomentumApp extends StatelessWidget {
  const FitMomentumApp({super.key});

  @override
  Widget build(BuildContext context) {
    final scheme = ColorScheme.fromSeed(
      seedColor: Colors.blue,
      brightness: Brightness.light,
    );
    return MaterialApp(
      title: 'FitMomentum',
      theme: ThemeData(
        colorScheme: scheme,
        useMaterial3: true,
        scaffoldBackgroundColor: scheme.surface,
        appBarTheme: AppBarTheme(
          backgroundColor: scheme.surface,
          foregroundColor: scheme.onSurface,
          elevation: 0,
          centerTitle: true,
        ),
        bottomNavigationBarTheme: BottomNavigationBarThemeData(
          backgroundColor: scheme.surface,
          selectedItemColor: scheme.primary,
          unselectedItemColor: scheme.onSurfaceVariant,
          selectedIconTheme: const IconThemeData(size: 26),
          unselectedIconTheme: const IconThemeData(size: 24),
          type: BottomNavigationBarType.fixed,
          showUnselectedLabels: true,
        ),
      ),
      routes: {
        '/profile': (context) =>
            const ProfileOnboardingPage(onFinishedRoute: '/'),
      },
      home: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentIndex = 0;

  static const _pages = [
    DashboardPage(),
    ChartsPage(),
    GoalsPage(),
    SettingsPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _currentIndex, children: _pages),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.show_chart),
            activeIcon: Icon(Icons.show_chart),
            label: 'Charts',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.flag_outlined),
            activeIcon: Icon(Icons.flag),
            label: 'Goals',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings_outlined),
            activeIcon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
        onTap: (i) => setState(() => _currentIndex = i),
      ),
    );
  }
}
