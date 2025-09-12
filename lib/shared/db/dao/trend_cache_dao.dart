import 'package:drift/drift.dart';
import 'package:fitmomentum/shared/db/tables_trend.dart';
import '../app_database.dart';
import '../../metrics/enums.dart';

part 'trend_cache_dao.g.dart';

@DriftAccessor(tables: [TrendCache])
class TrendCacheDao extends DatabaseAccessor<AppDatabase>
    with _$TrendCacheDaoMixin {
  TrendCacheDao(super.db);

  Future<void> upsertTrend({
    required int dayUtc,
    required AggMetric metric,
    required TrendMethod method,
    required int window,
    required double value,
  }) async {
    await into(attachedDatabase.trendCache).insertOnConflictUpdate(
      TrendCacheCompanion(
        dayUtc: Value(dayUtc),
        metric: Value(metric),
        method: Value(method),
        window: Value(window),
        value: Value(value),
      ),
    );
  }

  Future<List<TrendCacheData>> getTrend(
    AggMetric metric,
    TrendMethod method,
    int window, {
    int? fromUtc,
    int? toUtc,
  }) {
    final q = select(attachedDatabase.trendCache)
      ..where(
        (t) =>
            t.metric.equalsValue(metric) &
            t.method.equalsValue(method) &
            t.window.equals(window),
      );
    if (fromUtc != null) q.where((t) => t.dayUtc.isBiggerOrEqualValue(fromUtc));
    if (toUtc != null) q.where((t) => t.dayUtc.isSmallerThanValue(toUtc));
    q.orderBy([(t) => OrderingTerm.asc(t.dayUtc)]);
    return q.get();
  }
}
