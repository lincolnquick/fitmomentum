// lib/shared/db/tables_characteristics.dart
import 'package:drift/drift.dart';

class UserCharacteristics extends Table {
  // Single row with fixed id = 1
  IntColumn get id => integer().withDefault(const Constant(1))();

  DateTimeColumn get dateOfBirth => dateTime().nullable()();
  TextColumn get sex => text().withDefault(const Constant('unknown'))();
  RealColumn get heightMeters => real().nullable()();
  RealColumn get weightKg => real().nullable()();

  DateTimeColumn get capturedAt => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}
