import 'package:drift/drift.dart';
import 'package:fitmomentum/shared/db/tables_daily.dart';
import 'package:fitmomentum/shared/db/tables_raw.dart';
import '../app_database.dart';
import '../../metrics/enums.dart';

part 'daily_agg_dao.g.dart';

@DriftAccessor(tables: [DailyAgg, HealthSample])
class DailyAggDao extends DatabaseAccessor<AppDatabase>
    with _$DailyAggDaoMixin {
  DailyAggDao(super.db);

  Future<void> upsertDaily({
    required int dayUtc,
    required AggMetric metric,
    required UnitKind unit,
    double? sum,
    double? avg,
    double? min,
    double? max,
    int count = 0,
    String? primarySource,
  }) async {
    final now = DateTime.now().millisecondsSinceEpoch;
    await into(attachedDatabase.dailyAgg).insertOnConflictUpdate(
      DailyAggCompanion(
        dayUtc: Value(dayUtc),
        metric: Value(metric),
        unit: Value(unit),
        sum: Value(sum),
        avg: Value(avg),
        min: Value(min),
        max: Value(max),
        count: Value(count),
        primarySource: Value(primarySource),
        updatedAt: Value(now),
      ),
    );
  }

  Future<List<DailyAggData>> getSeries(
    AggMetric metric, {
    int? fromUtc,
    int? toUtc,
  }) {
    final q = select(attachedDatabase.dailyAgg)
      ..where((t) => t.metric.equalsValue(metric));
    if (fromUtc != null) q.where((t) => t.dayUtc.isBiggerOrEqualValue(fromUtc));
    if (toUtc != null) q.where((t) => t.dayUtc.isSmallerThanValue(toUtc));
    q.orderBy([(t) => OrderingTerm.asc(t.dayUtc)]);
    return q.get();
  }
}
