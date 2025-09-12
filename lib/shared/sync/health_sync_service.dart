import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:health/health.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:fitmomentum/shared/db/app_database.dart';
import 'package:fitmomentum/shared/repo/metrics_repository.dart';
import 'package:fitmomentum/shared/ingest/ingest_service.dart';

import 'dart:developer' as dev; // structured logs
import 'package:fitmomentum/shared/sync/debug_sync_prefs.dart';

/// HealthSyncService
/// ------------------
/// Single place to:
///  - Request permissions (profile + timeseries)
///  - Read from Apple Health / Health Connect
///  - Ingest into Drift (RAW + Daily)
///  - Keep a last-sync anchor in SharedPreferences
///  - Offer manual `syncNow()` and app-resume hook
///  - Register background refresh (via background_fetch)
class HealthSyncService {
  static const _kPrefsKeyLastSync = 'health.last_sync_ms';
  static const _kPrefsKeyProfileSync = 'health.profile_last_sync_ms';

  final AppDatabase db;
  final MetricsRepository repo;
  final Health health;
  final String platform; // 'ios' | 'android'

  HealthSyncService({
    required this.db,
    required this.repo,
    required this.health,
    required this.platform,
  });

  /// Types we use
  static const profileTypes = <HealthDataType>[
    HealthDataType.BIRTH_DATE,
    HealthDataType.GENDER,
    HealthDataType.HEIGHT,
    HealthDataType.WEIGHT, // optionally seed latest weight in profile too
  ];

  static const seriesTypes = <HealthDataType>[
    HealthDataType.WEIGHT,
    HealthDataType.BODY_FAT_PERCENTAGE,
    HealthDataType.STEPS,
    HealthDataType.DISTANCE_WALKING_RUNNING,
    HealthDataType.ACTIVE_ENERGY_BURNED,
    HealthDataType.BASAL_ENERGY_BURNED,
    HealthDataType.DIETARY_ENERGY_CONSUMED,
    // Optional raw-only types:
    HealthDataType.FLIGHTS_CLIMBED,
    HealthDataType.EXERCISE_TIME,
    HealthDataType.WORKOUT,
    HealthDataType.DIETARY_CARBS_CONSUMED,
    HealthDataType.DIETARY_PROTEIN_CONSUMED,
    HealthDataType.DIETARY_FATS_CONSUMED,
    HealthDataType.DIETARY_FIBER,
    HealthDataType.DIETARY_SODIUM,
  ];

  /// Call this once early (e.g., app start) to configure the plugin.
  Future<void> configure() async {
    await health.configure();
  }

  /// Ask for profile + series permissions (call from onboarding or settings)
  Future<bool> requestPermissions() async {
    final ok1 = await health.requestAuthorization(profileTypes);
    final ok2 = await health.requestAuthorization(seriesTypes);
    return ok1 && ok2;
  }

  // Optionally expose a custom logger
  void _log(String msg, {bool force = false}) {
    if (force || kDebugMode) {
      dev.log(msg, name: 'HealthSync');
    }
  }

  static const defaultDeltaDays = 30;
  static const defaultFullDays = 365;

  static const minimalSeriesForDev = <HealthDataType>[
    HealthDataType.WEIGHT,
    HealthDataType.BODY_FAT_PERCENTAGE,
  ];

  /// Public entry: run a sync now.
  /// - If [full] is true, pull last 365 days; else pull since last successful sync (or 30 days fallback).
  /// - Also refresh profile data occasionally (>= 7 days old).
  Future<void> syncNow({bool full = false}) async {
    final prefs = await SharedPreferences.getInstance();
    final dbg = DebugSyncPrefs(prefs);
    final now = DateTime.now();
    final swAll = Stopwatch()..start();
    _log('syncNow(full=$full) start @ $now, platform=$platform');

    // Profile sync: once a week (or on first run)
    final lastProfileMs = prefs.getInt(_kPrefsKeyProfileSync);
    final needProfile =
        lastProfileMs == null ||
        DateTime.fromMillisecondsSinceEpoch(
          lastProfileMs,
        ).isBefore(now.subtract(const Duration(days: 7)));
    if (needProfile) {
      final sw = Stopwatch()..start();
      try {
        _log('Profile sync…');
        await _syncProfile();
        await prefs.setInt(_kPrefsKeyProfileSync, now.millisecondsSinceEpoch);
        _log('Profile sync done in ${sw.elapsedMilliseconds}ms');
      } catch (e, st) {
        debugPrint('Health profile sync failed: $e\n$st');
      }
    }

    // Series sync
    DateTime start;
    if (true) {
      start = now.subtract(const Duration(days: 365));
      _log('Full sync window: 365d → $start → $now');
    } else {
      final lastMs = prefs.getInt(_kPrefsKeyLastSync);
      start = lastMs != null
          ? DateTime.fromMillisecondsSinceEpoch(
              lastMs,
            ).subtract(const Duration(days: 1))
          : now.subtract(const Duration(days: 90));
      _log('Delta sync window (last=${lastMs ?? 'none'}) → $start → $now');
    }

    try {
      final swFetch = Stopwatch()..start();
      _log('Fetch from Health…');
      final points = await health.getHealthDataFromTypes(
        startTime: start,
        endTime: now,
        types: seriesTypes,
      );
      _log(
        'Fetch OK in ${swFetch.elapsedMilliseconds}ms (points=${points.length})',
      );
      final swIngest = Stopwatch()..start();
      await IngestService(db).ingestPoints(points, platform: platform);
      _log('Ingest OK in ${swIngest.elapsedMilliseconds}ms');
      await prefs.setInt(_kPrefsKeyLastSync, now.millisecondsSinceEpoch);
    } catch (e, st) {
      debugPrint('Health series sync failed: $e\n$st');
      _log('Fetch failed: $e\n$st', force: true);
      rethrow;
    }
    _log('syncNow done in ${swAll.elapsedMilliseconds}ms');
    await repo.debugPrintAllCounts();
  }

  /// Minimal profile sync → UserCharacteristics in repo
  Future<void> _syncProfile() async {
    final earliest = DateTime(1900);
    final now = DateTime.now();
    final pts = await health.getHealthDataFromTypes(
      startTime: earliest,
      endTime: now,
      types: profileTypes,
    );

    DateTime? dob;
    String sex = 'unknown';
    double? heightM;
    double? weightKg;

    for (final p in pts) {
      final t = p.type;
      final v = _extractNumeric(p.value, t);
      if (t == HealthDataType.BIRTH_DATE) {
        // Some platforms deliver a date string in value; if numeric, ignore
        try {
          dob = DateTime.parse(p.value.toString());
        } catch (_) {}
        continue;
      }
      if (t == HealthDataType.GENDER) {
        sex = p.value.toString().toLowerCase();
        continue;
      }
      if (t == HealthDataType.HEIGHT && v != null) heightM = v.toDouble();
      if (t == HealthDataType.WEIGHT && v != null) weightKg = v.toDouble();
    }

    await repo.upsertUserCharacteristics(
      dateOfBirth: dob,
      sex: sex,
      heightMeters: heightM,
      weightKg: weightKg,
      capturedAt: DateTime.now().toUtc(),
    );
  }

  /// On app lifecycle resume
  Future<void> onAppResume() async {
    try {
      await syncNow(full: false);
    } catch (_) {}
  }

  // ----------------------------------------------------------------------------
  // Helpers (duplicated light-weight extractors to avoid importing full ingest)
  // ----------------------------------------------------------------------------
  double? _extractNumeric(HealthValue v, HealthDataType t) {
    if (v is NumericHealthValue) return v.numericValue.toDouble();
    if (v is NutritionHealthValue) {
      switch (t) {
        case HealthDataType.DIETARY_ENERGY_CONSUMED:
          return v.calories?.toDouble();
        case HealthDataType.DIETARY_CARBS_CONSUMED:
          return v.carbs?.toDouble();
        case HealthDataType.DIETARY_PROTEIN_CONSUMED:
          return v.protein?.toDouble();
        case HealthDataType.DIETARY_FATS_CONSUMED:
          return v.fat?.toDouble();
        case HealthDataType.DIETARY_FIBER:
          return v.fiber?.toDouble();
        case HealthDataType.DIETARY_SODIUM:
          return v.sodium?.toDouble();
        default:
          return null;
      }
    }
    return null;
  }
}
