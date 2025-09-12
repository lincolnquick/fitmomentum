import 'dart:math';
import 'package:health/health.dart';
import '../metrics/enums.dart';
import '../metrics/mappers.dart';
import '../db/app_database.dart';
import '../db/dao/health_sample_dao.dart';
import '../db/dao/daily_agg_dao.dart';

/// Minimal ingest -> raw + daily (sum/avg rules) for health: ^13.1.4
class IngestService {
  final AppDatabase db;
  final HealthSampleDao rawDao;
  final DailyAggDao dailyDao;

  IngestService(this.db)
    : rawDao = HealthSampleDao(db),
      dailyDao = DailyAggDao(db);

  // --- Helpers ---------------------------------------------------------------

  double? _extractNumeric(HealthValue v, HealthDataType t) {
    if (v is NumericHealthValue) return v.numericValue.toDouble();

    // Nutrition values (grams, kcal, mg). Only extract for types you care about.
    if (v is NutritionHealthValue) {
      switch (t) {
        case HealthDataType.DIETARY_ENERGY_CONSUMED:
          return v.calories?.toDouble(); // kcal
        case HealthDataType.DIETARY_CARBS_CONSUMED:
          return v.carbs?.toDouble(); // grams
        case HealthDataType.DIETARY_PROTEIN_CONSUMED:
          return v.protein?.toDouble(); // grams
        case HealthDataType.DIETARY_FATS_CONSUMED:
          return v.fat?.toDouble(); // grams
        case HealthDataType.DIETARY_FIBER:
          return v.fiber?.toDouble(); // grams
        case HealthDataType.DIETARY_SODIUM:
          return v.sodium?.toDouble(); // milligrams
        default:
          return null;
      }
    }
    return null; // ignore workouts/audiograms/etc. here
  }

  double _toCanonical(HealthDataType t, double v) {
    switch (t) {
      case HealthDataType.WEIGHT:
        return v; // kg
      case HealthDataType.BODY_FAT_PERCENTAGE:
        return v / 100.0; // % -> fraction
      case HealthDataType.DISTANCE_WALKING_RUNNING:
        return v; // m
      case HealthDataType.ACTIVE_ENERGY_BURNED:
      case HealthDataType.BASAL_ENERGY_BURNED:
      case HealthDataType.DIETARY_ENERGY_CONSUMED:
        return v; // kcal
      case HealthDataType.STEPS:
      case HealthDataType.HEART_RATE:
        return v; // count / bpm
      // Nutrition macros as-is (grams, milligrams)
      case HealthDataType.DIETARY_CARBS_CONSUMED:
      case HealthDataType.DIETARY_PROTEIN_CONSUMED:
      case HealthDataType.DIETARY_FATS_CONSUMED:
      case HealthDataType.DIETARY_FIBER:
        return v; // grams
      case HealthDataType.DIETARY_SODIUM:
        return v; // milligrams
      default:
        return v;
    }
  }

  UnitKind _unitOf(HealthDataType t) {
    switch (t) {
      case HealthDataType.WEIGHT:
        return UnitKind.kg;
      case HealthDataType.BODY_FAT_PERCENTAGE:
        return UnitKind.fraction;
      case HealthDataType.STEPS:
        return UnitKind.count;
      case HealthDataType.DISTANCE_WALKING_RUNNING:
        return UnitKind.m;
      case HealthDataType.ACTIVE_ENERGY_BURNED:
      case HealthDataType.BASAL_ENERGY_BURNED:
      case HealthDataType.DIETARY_ENERGY_CONSUMED:
        return UnitKind.kcal;
      case HealthDataType.HEART_RATE:
        return UnitKind.bpm;
      // nutrition
      case HealthDataType.DIETARY_CARBS_CONSUMED:
      case HealthDataType.DIETARY_PROTEIN_CONSUMED:
      case HealthDataType.DIETARY_FATS_CONSUMED:
      case HealthDataType.DIETARY_FIBER:
        return UnitKind.g;
      case HealthDataType.DIETARY_SODIUM:
        return UnitKind.mg;
      default:
        return UnitKind.kcal; // fallback
    }
  }

  int _dayUtc00(DateTime dtUtc) =>
      DateTime.utc(dtUtc.year, dtUtc.month, dtUtc.day).millisecondsSinceEpoch;

  // --- Public ---------------------------------------------------------------

  /// Ingest a batch of HealthDataPoint and write RAW + Daily aggregates.
  Future<void> ingestPoints(
    List<HealthDataPoint> points, {
    required String platform, // e.g., 'ios' | 'android'
  }) async {
    // Group daily values by (day, AggMetric) to compute daily rollups.
    final dailyBuckets = <int, Map<AggMetric, List<double>>>{};

    for (final p in points) {
      final type = p.type;

      // 1) extract numeric
      final numeric = _extractNumeric(p.value, type);
      if (numeric == null) continue;

      // 2) canonicalize value
      final valueCanonical = _toCanonical(type, numeric);

      final startUtc = p.dateFrom.toUtc().millisecondsSinceEpoch;
      final endUtc = p.dateTo.toUtc().millisecondsSinceEpoch;

      // 3) Write RAW (idempotent upsert via hash in DAO)
      await rawDao.upsertRawSample(
        platform: platform,
        rawType: type.name, // HealthDataType enum name
        rawUnit: p.unit.name, // HealthDataUnit enum name
        value: valueCanonical,
        startAt: startUtc,
        endAt: endUtc,
        source: p.sourceId, // string
        deviceName: p.sourceName, // human-readable device/app name
        deviceModel: null, // none provided by plugin
        wasUserEntered: p.recordingMethod == RecordingMethod.manual,
        metadata: {
          'sourcePlatform': p.sourcePlatform.name,
          'sourceDeviceId': p.sourceDeviceId,
          // add any other fields from HealthDataPoint you want to retain
        },
      );

      // 4) Map to AggMetric (if applicable)
      final agg = type
          .toAggMetric(); // your mapper must support the types you query
      if (agg == null) continue;

      final day = _dayUtc00(p.dateTo.toUtc());
      final map = dailyBuckets.putIfAbsent(
        day,
        () => <AggMetric, List<double>>{},
      );
      map.putIfAbsent(agg, () => <double>[]).add(valueCanonical);
    }

    // 5) Compute per-day aggregates and UPSERT into DailyAgg
    for (final entry in dailyBuckets.entries) {
      final day = entry.key;
      final metrics = entry.value;

      for (final m in metrics.keys) {
        final vals = metrics[m]!;
        final sum = vals.fold<double>(0, (a, b) => a + b);
        final avg = vals.isEmpty ? null : sum / vals.length;
        final minv = vals.isEmpty ? null : vals.reduce(min);
        final maxv = vals.isEmpty ? null : vals.reduce(max);

        await dailyDao.upsertDaily(
          dayUtc: day,
          metric: m,
          unit: m.canonicalUnit, // from your enums/mappers
          sum:
              (m == AggMetric.steps ||
                  m == AggMetric.activeKcal ||
                  m == AggMetric.basalKcal ||
                  m == AggMetric.calInKcal ||
                  m == AggMetric.distanceM)
              ? sum
              : null,
          avg:
              (m == AggMetric.weightKg ||
                  m == AggMetric.bodyFatFraction ||
                  m == AggMetric.heartRateBpm)
              ? avg
              : null,
          min: minv,
          max: maxv,
          count: vals.length,
          primarySource: null,
        );
      }

      // 6) Derived metrics (requires primitives present)
      Future<double?> getAvg(AggMetric metric) async {
        final q = db.select(db.dailyAgg)
          ..where((t) => t.dayUtc.equals(day))
          ..where((t) => t.metric.equalsValue(metric));
        final rows = await q.get();
        return rows.isEmpty ? null : rows.first.avg;
      }

      Future<double?> getSum(AggMetric metric) async {
        final q = db.select(db.dailyAgg)
          ..where((t) => t.dayUtc.equals(day))
          ..where((t) => t.metric.equalsValue(metric));
        final rows = await q.get();
        return rows.isEmpty ? null : rows.first.sum;
      }

      // Derived: lean/fat mass (if weight + body fat fraction available)
      final weight = await getAvg(AggMetric.weightKg);
      final bff = await getAvg(AggMetric.bodyFatFraction);
      if (weight != null && bff != null) {
        final lean = (1 - bff) * weight;
        final fat = weight - lean;
        await dailyDao.upsertDaily(
          dayUtc: day,
          metric: AggMetric.leanMassKg,
          unit: UnitKind.kg,
          avg: lean,
          count: 1,
        );
        await dailyDao.upsertDaily(
          dayUtc: day,
          metric: AggMetric.fatMassKg,
          unit: UnitKind.kg,
          avg: fat,
          count: 1,
        );
      }

      // Derived: calOut = active + basal
      final active = await getSum(AggMetric.activeKcal) ?? 0.0;
      final basal = await getSum(AggMetric.basalKcal) ?? 0.0;
      final calOut = active + basal;

      await dailyDao.upsertDaily(
        dayUtc: day,
        metric: AggMetric.calOutKcal,
        unit: UnitKind.kcal,
        sum: calOut,
        count: 1,
      );

      // Derived: net = calIn - calOut
      final calIn = await getSum(AggMetric.calInKcal);
      if (calIn != null) {
        final net = calIn - calOut;
        await dailyDao.upsertDaily(
          dayUtc: day,
          metric: AggMetric.netCalKcal,
          unit: UnitKind.kcal,
          sum: net,
          count: 1,
        );
      }
    }
  }
}
