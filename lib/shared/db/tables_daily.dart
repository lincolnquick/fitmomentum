import 'package:drift/drift.dart';
import 'enum_converters.dart';

class DailyAgg extends Table {
  IntColumn get dayUtc => integer()(); // 00:00 UTC epoch ms
  TextColumn get metric => text().map(aggMetricConv)();
  TextColumn get unit => text().map(unitKindConv)();

  RealColumn get sum => real().nullable()();
  RealColumn get avg => real().nullable()();
  RealColumn get min => real().nullable()();
  RealColumn get max => real().nullable()();
  IntColumn get count => integer().withDefault(const Constant(0))();

  TextColumn get primarySource => text().nullable()();
  IntColumn get updatedAt => integer()();

  @override
  Set<Column> get primaryKey => {dayUtc, metric};
}
