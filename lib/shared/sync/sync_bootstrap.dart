import 'dart:async';
import 'package:flutter/material.dart';
import 'package:health/health.dart';

import 'package:fitmomentum/shared/db/app_database.dart';
import 'package:fitmomentum/shared/repo/metrics_repository.dart';
import 'package:fitmomentum/shared/sync/health_sync_service.dart';

/// SyncBootstrap wires HealthSyncService to app lifecycle (resume) and exposes a singleton.
class SyncBootstrap with WidgetsBindingObserver {
  SyncBootstrap._(this.service);
  static SyncBootstrap? _instance;
  final HealthSyncService service;

  static SyncBootstrap ensure({
    required AppDatabase db,
    required MetricsRepository repo,
    required String platform,
  }) {
    return _instance ??= SyncBootstrap._(
      HealthSyncService(
        db: db,
        repo: repo,
        health: Health(),
        platform: platform,
      ),
    );
  }

  Future<void> init() async {
    WidgetsBinding.instance.addObserver(this);
    await service.configure();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      unawaited(service.onAppResume());
    }
  }

  /// manual trigger from UI (pull-to-refresh, post-onboarding, settings)
  Future<void> manualSync({bool full = false}) => service.syncNow(full: full);
}
