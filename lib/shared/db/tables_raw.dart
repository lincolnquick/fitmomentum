import 'package:drift/drift.dart';

class HealthSample extends Table {
  TextColumn get id => text()(); // dedup hash
  TextColumn get platform => text()(); // 'ios' | 'android'
  TextColumn get rawType => text()(); // HealthDataType.name
  TextColumn get rawUnit => text()(); // original unit ('lb','kJ','count')
  RealColumn get value => real()();
  IntColumn get startAt => integer()(); // epoch ms UTC
  IntColumn get endAt => integer()();
  TextColumn get source => text().nullable()();
  TextColumn get deviceName => text().nullable()();
  TextColumn get deviceModel => text().nullable()();
  BoolColumn get wasUserEntered =>
      boolean().withDefault(const Constant(false))();
  TextColumn get metadataJson => text().nullable()();
  IntColumn get insertedAt => integer()();
  IntColumn get updatedAt => integer()();

  @override
  Set<Column> get primaryKey => {id};
}
