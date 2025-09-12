import 'package:health/health.dart' show HealthDataType;
import 'enums.dart';

extension HealthTypeToAgg on HealthDataType {
  AggMetric? toAggMetric() {
    switch (this) {
      case HealthDataType.WEIGHT:
        return AggMetric.weightKg;
      case HealthDataType.BODY_FAT_PERCENTAGE:
        return AggMetric.bodyFatFraction;
      case HealthDataType.STEPS:
        return AggMetric.steps;
      case HealthDataType.DISTANCE_WALKING_RUNNING:
        return AggMetric.distanceM;
      case HealthDataType.ACTIVE_ENERGY_BURNED:
        return AggMetric.activeKcal;
      case HealthDataType.BASAL_ENERGY_BURNED:
        return AggMetric.basalKcal;
      case HealthDataType.DIETARY_ENERGY_CONSUMED:
        return AggMetric.calInKcal;
      case HealthDataType.HEART_RATE:
        return AggMetric.heartRateBpm;
      case HealthDataType.DIETARY_FATS_CONSUMED:
        return AggMetric.fatsG;
      case HealthDataType.DIETARY_PROTEIN_CONSUMED:
        return AggMetric.proteinG;
      case HealthDataType.DIETARY_CARBS_CONSUMED:
        return AggMetric.carbsG;
      case HealthDataType.DIETARY_FIBER:
        return AggMetric.fiberG;
      case HealthDataType.DIETARY_SODIUM:
        return AggMetric.sodiumMg;
      default:
        return null;
    }
  }
}

extension AggMetricUnits on AggMetric {
  UnitKind get canonicalUnit {
    switch (this) {
      case AggMetric.weightKg:
      case AggMetric.leanMassKg:
      case AggMetric.fatMassKg:
        return UnitKind.kg;
      case AggMetric.bodyFatFraction:
        return UnitKind.fraction;
      case AggMetric.steps:
        return UnitKind.count;
      case AggMetric.distanceM:
        return UnitKind.m;
      case AggMetric.activeKcal:
      case AggMetric.basalKcal:
      case AggMetric.calInKcal:
      case AggMetric.calOutKcal:
      case AggMetric.netCalKcal:
        return UnitKind.kcal;
      case AggMetric.heartRateBpm:
        return UnitKind.bpm;
      case AggMetric.carbsG:
      case AggMetric.proteinG:
      case AggMetric.fatsG:
      case AggMetric.fiberG:
        return UnitKind.g;
      case AggMetric.sodiumMg:
        return UnitKind.mg;
    }
  }
}

extension AggMetricDerived on AggMetric {
  bool get isDerived =>
      this == AggMetric.leanMassKg ||
      this == AggMetric.fatMassKg ||
      this == AggMetric.netCalKcal ||
      this == AggMetric.calOutKcal;
}

extension UnitConversions on UnitKind {
  double toDisplay(double value) =>
      this == UnitKind.fraction ? value * 100.0 : value;
  double fromDisplay(double displayValue) =>
      this == UnitKind.fraction ? displayValue / 100.0 : displayValue;
}
