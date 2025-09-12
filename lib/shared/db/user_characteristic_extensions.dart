import 'package:fitmomentum/shared/db/app_database.dart';

extension UserCharacteristicHelpers on UserCharacteristic {
  /// Age in years (fractional).
  double get ageYears {
    if (dateOfBirth == null) return 0.0;
    final difference = DateTime.now().difference(dateOfBirth!);
    return difference.inDays.toDouble() / 365.25;
  }

  /// Formatted label (1 decimal if ≥ 1 year, 2 decimals if < 1).
  String get ageYearsLabel {
    if (dateOfBirth == null) return '—';
    final yrs = ageYears;
    return yrs >= 1 ? yrs.toStringAsFixed(1) : yrs.toStringAsFixed(2);
  }

  /// Height in cm (if meters set).
  double? get heightCm => heightMeters != null ? heightMeters! * 100.0 : null;

  String get heightLabel =>
      heightCm != null ? '${heightCm!.toStringAsFixed(1)} cm' : '—';

  /// Weight in pounds (if kg set).
  double? get weightLb => weightKg != null ? weightKg! * 2.20462 : null;

  String get weightLabel =>
      weightKg != null ? '${weightKg!.toStringAsFixed(1)} kg' : '—';
}
