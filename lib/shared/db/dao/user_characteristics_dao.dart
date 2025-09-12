import 'package:drift/drift.dart';
import 'package:fitmomentum/shared/db/app_database.dart';
import 'package:fitmomentum/shared/db/tables_characteristics.dart';

part 'user_characteristics_dao.g.dart';

@DriftAccessor(tables: [UserCharacteristics])
class UserCharacteristicsDao extends DatabaseAccessor<AppDatabase>
    with _$UserCharacteristicsDaoMixin {
  UserCharacteristicsDao(super.db);

  // NOTE: Data class is singular: UserCharacteristic
  Future<UserCharacteristic?> getRow() {
    final t = attachedDatabase.userCharacteristics;
    return attachedDatabase.select(t).getSingleOrNull();
  }

  Stream<UserCharacteristic?> watchRow() {
    final t = attachedDatabase.userCharacteristics;
    return attachedDatabase.select(t).watchSingleOrNull();
  }

  Future<void> upsert({
    DateTime? dateOfBirth,
    String? sex,
    double? heightMeters,
    double? weightKg,
    DateTime? capturedAt,
  }) async {
    await into(attachedDatabase.userCharacteristics).insertOnConflictUpdate(
      UserCharacteristicsCompanion(
        id: const Value(1),
        dateOfBirth: Value(dateOfBirth),
        sex: sex == null ? const Value.absent() : Value(sex),
        heightMeters: Value(heightMeters),
        weightKg: Value(weightKg),
        capturedAt: Value(capturedAt),
      ),
    );
  }
}
