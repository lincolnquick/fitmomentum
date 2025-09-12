/// Normalized daily metrics used across charts and ML.
enum AggMetric {
  weightKg,
  bodyFatFraction,
  leanMassKg,
  fatMassKg,
  steps,
  distanceM,
  activeKcal,
  basalKcal,
  calInKcal,
  calOutKcal,
  netCalKcal,
  heartRateBpm,
  carbsG,
  proteinG,
  fatsG,
  fiberG,
  sodiumMg,
}

enum UnitKind { kg, g, mg, fraction, count, m, kcal, bpm, cm, percent }

enum TrendMethod { ema7, ema30, ema90, movingAvg7, movingAvg30, lowess }

enum PredictionTarget { weightKg, bodyFatFraction, netCalKcal, leanMassKg }
