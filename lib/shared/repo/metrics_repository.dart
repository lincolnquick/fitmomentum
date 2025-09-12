import 'dart:developer' as dev;

import '../db/app_database.dart';
import '../db/dao/daily_agg_dao.dart';
import '../db/dao/trend_cache_dao.dart';
import '../db/dao/user_characteristics_dao.dart';
import '../metrics/enums.dart';

class MetricsRepository {
  final AppDatabase db;
  final DailyAggDao _daily;
  final TrendCacheDao _trend;
  final UserCharacteristicsDao _uc;

  MetricsRepository(this.db)
    : _daily = DailyAggDao(db),
      _trend = TrendCacheDao(db),
      _uc = UserCharacteristicsDao(db);

  Future<List<DailyAggData>> getDailySeries(
    AggMetric metric, {
    DateTime? from,
    DateTime? to,
  }) async {
    final f = from?.toUtc().millisecondsSinceEpoch;
    final t = to?.toUtc().millisecondsSinceEpoch;
    return _daily.getSeries(metric, fromUtc: f, toUtc: t);
  }

  Future<List<TrendCacheData>> getTrend(
    AggMetric metric,
    TrendMethod method,
    int window, {
    DateTime? from,
    DateTime? to,
  }) async {
    final f = from?.toUtc().millisecondsSinceEpoch;
    final t = to?.toUtc().millisecondsSinceEpoch;
    return _trend.getTrend(metric, method, window, fromUtc: f, toUtc: t);
  }

  Future<UserCharacteristic?> getUserCharacteristics() => _uc.getRow();
  Stream<UserCharacteristic?> watchUserCharacteristics() => _uc.watchRow();

  /// Upsert all (only fields you pass are updated).
  Future<void> upsertUserCharacteristics({
    DateTime? dateOfBirth,
    String? sex,
    double? heightMeters,
    double? weightKg,
    DateTime? capturedAt,
  }) => _uc.upsert(
    dateOfBirth: dateOfBirth,
    sex: sex,
    heightMeters: heightMeters,
    weightKg: weightKg,
    capturedAt: capturedAt,
  );

  // Convenience setters
  Future<void> setHeightMeters(double h) =>
      _uc.upsert(heightMeters: h, capturedAt: DateTime.now().toUtc());

  Future<void> setWeightKg(double w) =>
      _uc.upsert(weightKg: w, capturedAt: DateTime.now().toUtc());

  Future<void> setSex(String s) =>
      _uc.upsert(sex: s, capturedAt: DateTime.now().toUtc());

  /// Debug: print how many daily rows exist for each AggMetric.
  Future<void> debugPrintDailyCounts() async {
    final rows = await (db.select(db.dailyAgg)).get();

    final counts = <AggMetric, int>{};
    for (final row in rows) {
      counts[row.metric] = (counts[row.metric] ?? 0) + 1;
    }

    dev.log('--- DailyAgg counts ---');
    for (final e in counts.entries) {
      dev.log('${e.key}: ${e.value}');
    }
    dev.log('Total rows: ${rows.length}');
  }

  /// Debug: print how many raw samples exist for each HealthDataType.
  Future<void> debugPrintRawCounts() async {
    final rows = await (db.select(db.healthSample)).get();

    final counts = <String, int>{};
    for (final row in rows) {
      counts[row.rawType] = (counts[row.rawType] ?? 0) + 1;
    }

    dev.log('--- Raw HealthSample counts ---');
    for (final e in counts.entries) {
      dev.log('${e.key}: ${e.value}');
    }
    dev.log('Total rows: ${rows.length}');
  }

  /// Debug: print counts for trend values (smoothed series).
  Future<void> debugPrintTrendCounts() async {
    final rows = await (db.select(db.trendCache)).get();

    final counts = <AggMetric, int>{};
    for (final row in rows) {
      counts[row.metric] = (counts[row.metric] ?? 0) + 1;
    }

    dev.log('--- Trend counts ---');
    for (final e in counts.entries) {
      dev.log('${e.key}: ${e.value}');
    }
    dev.log('Total rows: ${rows.length}');
  }

  /// Debug: print counts for predictions (forecasted values).
  Future<void> debugPrintPredictedCounts() async {
    final rows = await (db.select(db.prediction)).get();

    final counts = <PredictionTarget, int>{};
    for (final row in rows) {
      counts[row.target] = (counts[row.target] ?? 0) + 1;
    }

    dev.log('--- Predicted counts ---');
    for (final e in counts.entries) {
      dev.log('${e.key}: ${e.value}');
    }
    dev.log('Total rows: ${rows.length}');
  }

  /// Run all debug counters in sequence.
  Future<void> debugPrintAllCounts() async {
    await debugPrintRawCounts();
    await debugPrintDailyCounts();
    await debugPrintTrendCounts();
    await debugPrintPredictedCounts();
  }
}
