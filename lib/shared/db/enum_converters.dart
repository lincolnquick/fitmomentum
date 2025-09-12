import 'package:drift/drift.dart';
import '../metrics/enums.dart';

class EnumNameConverter<T extends Enum> extends TypeConverter<T, String> {
  final List<T> values;
  const EnumNameConverter(this.values);
  @override
  T fromSql(String fromDb) => values.firstWhere((e) => e.name == fromDb);
  @override
  String toSql(T value) => value.name;
}

const aggMetricConv = EnumNameConverter<AggMetric>(AggMetric.values);
const unitKindConv = EnumNameConverter<UnitKind>(UnitKind.values);
const trendMethodConv = EnumNameConverter<TrendMethod>(TrendMethod.values);
const predTargetConv = EnumNameConverter<PredictionTarget>(
  PredictionTarget.values,
);
