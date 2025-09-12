import 'package:drift/drift.dart';
import 'package:fitmomentum/shared/db/tables_predictions.dart';
import '../app_database.dart';
import '../../metrics/enums.dart';

part 'prediction_dao.g.dart';

@DriftAccessor(tables: [Prediction])
class PredictionDao extends DatabaseAccessor<AppDatabase>
    with _$PredictionDaoMixin {
  PredictionDao(super.db);

  Future<void> upsertPrediction({
    required int dayUtc,
    required PredictionTarget target,
    required double value,
    String? modelId,
    double? lower,
    double? upper,
  }) async {
    final now = DateTime.now().millisecondsSinceEpoch;
    await into(attachedDatabase.prediction).insertOnConflictUpdate(
      PredictionCompanion(
        dayUtc: Value(dayUtc),
        target: Value(target),
        value: Value(value),
        modelId: Value(modelId),
        lower: Value(lower),
        upper: Value(upper),
        generatedAt: Value(now),
      ),
    );
  }
}
