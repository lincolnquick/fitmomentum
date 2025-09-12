import 'package:drift/drift.dart';
import 'enum_converters.dart';

class Prediction extends Table {
  IntColumn get dayUtc => integer()();
  TextColumn get target => text().map(predTargetConv)();
  RealColumn get value => real()();
  TextColumn get modelId => text().nullable()();
  RealColumn get lower => real().nullable()();
  RealColumn get upper => real().nullable()();
  IntColumn get generatedAt => integer()();

  @override
  Set<Column> get primaryKey => {dayUtc, target};
}
