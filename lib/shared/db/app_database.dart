import 'package:fitmomentum/shared/metrics/enums.dart';
import 'package:fitmomentum/shared/db/enum_converters.dart';
import 'dart:io';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:fitmomentum/shared/db/dao/daily_agg_dao.dart';
import 'package:fitmomentum/shared/db/dao/health_sample_dao.dart';
import 'package:fitmomentum/shared/db/dao/prediction_dao.dart';
import 'package:fitmomentum/shared/db/dao/trend_cache_dao.dart';
import 'package:fitmomentum/shared/db/dao/user_characteristics_dao.dart';
import '../../core/paths.dart';
import 'tables_raw.dart';
import 'tables_daily.dart';
import 'tables_trend.dart';
import 'tables_predictions.dart';
import 'tables_characteristics.dart';

part 'app_database.g.dart';

@DriftDatabase(
  tables: [HealthSample, DailyAgg, TrendCache, Prediction, UserCharacteristics],
  daos: [
    HealthSampleDao,
    DailyAggDao,
    TrendCacheDao,
    PredictionDao,
    UserCharacteristicsDao,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase._internal(super.e);

  static Future<AppDatabase> open() async {
    final path = await AppPaths.dbPath();
    final file = File(path);
    final executor = NativeDatabase.createInBackground(file);
    return AppDatabase._internal(executor);
  }

  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (m) async {
      await m.createAll();
      // Seed rows e.g., sync_state
    },
    onUpgrade: (m, from, to) async {
      // Handle future schema migrations here
    },
    beforeOpen: (details) async {
      // Pragmas for safety & performance
      await customStatement('PRAGMA foreign_keys = ON;');
      await customStatement('PRAGMA journal_mode = WAL;');
      await customStatement('PRAGMA synchronous = NORMAL;');
    },
  );
}
