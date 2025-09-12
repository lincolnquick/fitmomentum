class UserCharacteristics {
  final DateTime? dateOfBirth;

  /// Use: 'male', 'female', 'other', or 'unknown'
  final String sex;
  final double? heightMeters;
  final double? weightKg;
  final DateTime? capturedAt;

  const UserCharacteristics({
    required this.dateOfBirth,
    required this.sex,
    required this.heightMeters,
    required this.weightKg,
    required this.capturedAt,
  });

  /// Convenience: sane defaults when creating from scratch
  factory UserCharacteristics.empty() => const UserCharacteristics(
    dateOfBirth: null,
    sex: 'unknown',
    heightMeters: null,
    weightKg: null,
    capturedAt: null,
  );

  UserCharacteristics copyWith({
    DateTime? dateOfBirth,
    String? sex,
    double? heightMeters,
    double? weightKg,
    DateTime? capturedAt,
    bool clearDob = false, // allow clearing DoB explicitly
  }) {
    return UserCharacteristics(
      dateOfBirth: clearDob ? null : (dateOfBirth ?? this.dateOfBirth),
      sex: sex ?? this.sex,
      heightMeters: heightMeters ?? this.heightMeters,
      weightKg: weightKg ?? this.weightKg,
      capturedAt: capturedAt ?? this.capturedAt,
    );
  }

  double get ageYears {
    if (dateOfBirth == null) return 0.0;
    final difference = DateTime.now().difference(dateOfBirth!);
    return difference.inDays.toDouble() / 365.25;
  }

  String get ageYearsLabel {
    if (dateOfBirth == null) return '—';
    final yrs = ageYears;
    return yrs >= 1 ? yrs.toStringAsFixed(1) : yrs.toStringAsFixed(2);
  }
}
