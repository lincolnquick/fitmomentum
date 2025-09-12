import 'dart:developer' as dev;
import 'package:health/health.dart';

class HealthUserSnapshot {
  final DateTime? dateOfBirth;
  final String sex; // "male" | "female" | "other" | "unknown"
  final double? heightMeters;
  final double? weightKg;
  final DateTime capturedAt;

  HealthUserSnapshot({
    required this.dateOfBirth,
    required this.sex,
    required this.heightMeters,
    required this.weightKg,
    required this.capturedAt,
  });
}

class HealthService {
  final Health _health = Health();

  Future<void> configure() async {
    await _health.configure();
  }

  // Check & request permissions (safe to call anytime)
  Future<bool> requestAuthorization() async {
    final types = <HealthDataType>[
      HealthDataType.HEIGHT,
      HealthDataType.WEIGHT,
      HealthDataType.BIRTH_DATE,
      HealthDataType.GENDER,

      HealthDataType.BODY_FAT_PERCENTAGE,

      HealthDataType.ACTIVE_ENERGY_BURNED,
      HealthDataType.BASAL_ENERGY_BURNED,
      HealthDataType.STEPS,
      HealthDataType.DISTANCE_WALKING_RUNNING,
      HealthDataType.FLIGHTS_CLIMBED,
      HealthDataType.WORKOUT,
      HealthDataType.EXERCISE_TIME,

      HealthDataType.DIETARY_ENERGY_CONSUMED,
      HealthDataType.DIETARY_CARBS_CONSUMED,
      HealthDataType.DIETARY_PROTEIN_CONSUMED,
      HealthDataType.DIETARY_FATS_CONSUMED,
      HealthDataType.DIETARY_FIBER,
      HealthDataType.DIETARY_SODIUM,
    ];

    final permissions = types.map((t) => HealthDataAccess.READ).toList();
    // If we already have them, great
    final already = await _health.hasPermissions(
      types,
      permissions: permissions,
    );
    if (already == true) {
      dev.log('Health permissions already granted for HEIGHT/WEIGHT');
    } else {
      dev.log('Requesting Health permissions for HEIGHT/WEIGHT…');
      final ok = await _health.requestAuthorization(types);
      if (!ok) return false;
    }

    return true;
  }

  Future<HealthUserSnapshot> readUser() async {
    final now = DateTime.now();
    final end = now;
    final start = DateTime(2000);

    // --- DOB & Sex (characteristics)
    DateTime? dob;
    String sex = 'unknown';
    try {
      final dobPoints = await _health.getHealthDataFromTypes(
        startTime: start,
        endTime: end,
        types: [HealthDataType.BIRTH_DATE],
      );
      dev.log('DOB points: ${dobPoints.length}');
      if (dobPoints.isNotEmpty) {
        dobPoints.sort((a, b) => b.dateTo.compareTo(a.dateTo));
        final v = dobPoints.last.value;
        dev.log('DOB first value runtimeType: ${v.runtimeType} v=$v');

        dob = DateTime.fromMillisecondsSinceEpoch(
          (v as NumericHealthValue).numericValue.toInt() * 1000,
        );
      }
    } catch (e) {
      dev.log('DOB read failed: $e');
    }
    try {
      final sexPoints = await _health.getHealthDataFromTypes(
        startTime: start,
        endTime: end,
        types: [HealthDataType.GENDER],
      );
      dev.log('Sex points: ${sexPoints.length}');
      if (sexPoints.isNotEmpty) {
        sexPoints.sort((a, b) => b.dateTo.compareTo(a.dateTo));
        final v = sexPoints.last.value;
        dev.log('Sex first value runtimeType: ${v.runtimeType} v=$v');

        sex = v.toJson()['string_value'].toLowerCase();
      }
    } catch (e) {
      dev.log('Sex read failed: $e');
    }

    // --- HEIGHT (most recent)
    double? heightM;
    try {
      final heightPoints = await _health.getHealthDataFromTypes(
        startTime: start,
        endTime: end,
        types: [HealthDataType.HEIGHT],
      );
      dev.log('HEIGHT points: ${heightPoints.length}');
      if (heightPoints.isNotEmpty) {
        heightPoints.sort((a, b) => b.dateTo.compareTo(a.dateTo));
        final v = heightPoints.first.value;
        dev.log('HEIGHT first value runtimeType: ${v.runtimeType} v=$v');

        // Handle both new and old shapes
        if (v is NumericHealthValue) {
          heightM = v.numericValue.toDouble();
        }
      }
    } catch (e) {
      dev.log('HEIGHT read failed: $e');
    }

    // --- WEIGHT (most recent)
    double? weightKg;
    try {
      final weightPoints = await _health.getHealthDataFromTypes(
        startTime: start,
        endTime: end,
        types: [HealthDataType.WEIGHT],
      );
      dev.log('WEIGHT points: ${weightPoints.length}');
      if (weightPoints.isNotEmpty) {
        weightPoints.sort((a, b) => b.dateTo.compareTo(a.dateTo));
        final v = weightPoints.first.value;
        dev.log('WEIGHT first value runtimeType: ${v.runtimeType} v=$v');

        if (v is NumericHealthValue) {
          weightKg = v.numericValue.toDouble();
        }
      }
    } catch (e) {
      dev.log('WEIGHT read failed: $e');
    }
    dev.log(
      'Snapshot -> dob=$dob sex=$sex heightM=$heightM weightKg=$weightKg',
    );

    return HealthUserSnapshot(
      dateOfBirth: dob,
      sex: sex,
      heightMeters: heightM,
      weightKg: weightKg,
      capturedAt: now,
    );
  }
}
