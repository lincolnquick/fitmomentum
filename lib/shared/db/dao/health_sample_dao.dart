import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:drift/drift.dart';
import 'package:fitmomentum/shared/db/tables_raw.dart';
import '../app_database.dart';

part 'health_sample_dao.g.dart';

@DriftAccessor(tables: [HealthSample])
class HealthSampleDao extends DatabaseAccessor<AppDatabase>
    with _$HealthSampleDaoMixin {
  HealthSampleDao(super.db);

  Future<void> upsertRawSample({
    required String platform,
    required String rawType,
    required String rawUnit,
    required double value,
    required int startAt,
    required int endAt,
    String? source,
    String? deviceName,
    String? deviceModel,
    bool wasUserEntered = false,
    Map<String, dynamic>? metadata,
  }) async {
    final id = _hash({
      'platform': platform,
      'rawType': rawType,
      'rawUnit': rawUnit,
      'value': value,
      'startAt': startAt,
      'endAt': endAt,
      'source': source,
      'deviceName': deviceName,
      'deviceModel': deviceModel,
      'wasUserEntered': wasUserEntered,
    });

    final now = DateTime.now().millisecondsSinceEpoch;

    await into(attachedDatabase.healthSample).insertOnConflictUpdate(
      HealthSampleCompanion.insert(
        id: id,
        platform: platform,
        rawType: rawType,
        rawUnit: rawUnit,
        value: value,
        startAt: startAt,
        endAt: endAt,
        source: Value(source),
        deviceName: Value(deviceName),
        deviceModel: Value(deviceModel),
        wasUserEntered: Value(wasUserEntered),
        metadataJson: Value(metadata == null ? null : jsonEncode(metadata)),
        insertedAt: now,
        updatedAt: now,
      ),
    );
  }

  String _hash(Map<String, Object?> m) =>
      sha1.convert(utf8.encode(jsonEncode(m))).toString();
}
