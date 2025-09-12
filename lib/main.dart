import 'package:fitmomentum/features/weight/weight_page.dart';
import 'package:fitmomentum/shared/db/app_database.dart';
import 'package:fitmomentum/shared/repo/metrics_repository.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'features/profile/view/profile_onboarding_page.dart';
import 'features/metrics/view/metrics_page.dart';
import 'package:provider/provider.dart';
import 'package:fitmomentum/shared/sync/sync_bootstrap.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Open DB once
  final db = await AppDatabase.open();

  // Create repo instance
  final repo = MetricsRepository(db);

  // Wire up Health sync (app resume + manual triggers)
  final sync = SyncBootstrap.ensure(
    db: db,
    repo: repo,
    platform: defaultTargetPlatform == TargetPlatform.iOS ? 'ios' : 'android',
  );
  await sync.init(); // configures health & attaches lifecycle observer

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
      title: 'Fit Momentum',
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
            const ProfileOnboardingPage(onFinishedRoute: '/metrics'),
        '/metrics': (context) => const MetricsPage(),
        '/weight': (context) => const WeightPage(),
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

  Widget _buildPage(int index) {
    switch (index) {
      case 0:
        return const ProfileOnboardingPage();
      case 1:
        return const MetricsPage();
      case 2:
        return const WeightPage();
      case 3:
        return const _SettingsPlaceholder();
      default:
        return const Center(child: Text('Unknown page'));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('FitMomentum')),
      body: _buildPage(_currentIndex),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.person), label: "Profile"),
          BottomNavigationBarItem(
            icon: Icon(Icons.analytics),
            label: "Metrics",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.monitor_weight),
            label: "Weight",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: "Settings",
          ),
        ],
        onTap: (i) => setState(() => _currentIndex = i),
      ),
    );
  }
}

class _SettingsPlaceholder extends StatelessWidget {
  const _SettingsPlaceholder();

  @override
  Widget build(BuildContext context) {
    return const Center(child: Text('Settings coming soon!'));
  }
}
