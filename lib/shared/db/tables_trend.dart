import 'package:drift/drift.dart';
import 'enum_converters.dart';

class TrendCache extends Table {
  IntColumn get dayUtc => integer()();
  TextColumn get metric => text().map(aggMetricConv)();
  TextColumn get method => text().map(trendMethodConv)();
  IntColumn get window => integer()(); // e.g., 7, 30, 90
  RealColumn get value => real()();

  @override
  Set<Column> get primaryKey => {dayUtc, metric, method, window};
}
