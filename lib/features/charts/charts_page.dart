import 'package:fitmomentum/shared/metrics/enums.dart';
import 'package:fitmomentum/shared/repo/metrics_repository.dart';
import 'package:fitmomentum/shared/sync/sync_bootstrap.dart';
import 'package:fitmomentum/shared/widgets/health_timeline_chart.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

enum _ChartMetric { weight, bodyFat, calories, activity }

class ChartsPage extends StatefulWidget {
  const ChartsPage({super.key});

  @override
  State<ChartsPage> createState() => _ChartsPageState();
}

class _ChartsPageState extends State<ChartsPage> {
  _ChartMetric _metric = _ChartMetric.weight;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Charts'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(52),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
            child: SegmentedButton<_ChartMetric>(
              segments: const [
                ButtonSegment(
                  value: _ChartMetric.weight,
                  icon: Icon(Icons.monitor_weight_outlined),
                  label: Text('Weight'),
                ),
                ButtonSegment(
                  value: _ChartMetric.bodyFat,
                  icon: Icon(Icons.percent),
                  label: Text('Body Fat'),
                ),
                ButtonSegment(
                  value: _ChartMetric.calories,
                  icon: Icon(Icons.local_fire_department_outlined),
                  label: Text('Calories'),
                ),
                ButtonSegment(
                  value: _ChartMetric.activity,
                  icon: Icon(Icons.directions_walk),
                  label: Text('Activity'),
                ),
              ],
              selected: {_metric},
              onSelectionChanged: (s) => setState(() => _metric = s.first),
              style: const ButtonStyle(
                visualDensity: VisualDensity(horizontal: -2, vertical: -2),
              ),
            ),
          ),
        ),
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    switch (_metric) {
      case _ChartMetric.weight:
        return const _WeightChartBody();
      case _ChartMetric.bodyFat:
        return _comingSoon('Body Fat %', Icons.percent, context);
      case _ChartMetric.calories:
        return _comingSoon('Calories', Icons.local_fire_department_outlined, context);
      case _ChartMetric.activity:
        return _comingSoon('Activity & Steps', Icons.directions_walk, context);
    }
  }

  Widget _comingSoon(String label, IconData icon, BuildContext ctx) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 56, color: Theme.of(ctx).colorScheme.outlineVariant),
          const SizedBox(height: 16),
          Text(
            '$label chart coming soon',
            style: Theme.of(ctx).textTheme.titleMedium?.copyWith(
              color: Theme.of(ctx).colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'This metric will be available in a future update.',
            style: Theme.of(ctx).textTheme.bodySmall?.copyWith(
              color: Theme.of(ctx).colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

/// Weight chart content extracted here to avoid nested Scaffolds.
class _WeightChartBody extends StatefulWidget {
  const _WeightChartBody();

  @override
  State<_WeightChartBody> createState() => _WeightChartBodyState();
}

class _WeightChartBodyState extends State<_WeightChartBody> {
  HealthTimeframe timeframe = HealthTimeframe.month;
  bool showLb = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final repo = context.read<MetricsRepository>();
      SyncBootstrap.ensure(
        db: repo.db,
        repo: repo,
        platform: Theme.of(context).platform == TargetPlatform.iOS
            ? 'ios'
            : 'android',
      ).manualSync(full: false);
    });
  }

  Future<List<HealthPoint>> _load() async {
    final repo = context.read<MetricsRepository>();
    final range = _rangeFor(timeframe);
    final rows = await repo.getDailySeries(
      AggMetric.weightKg,
      from: range.$1,
      to: range.$2,
    );
    return rows.where((r) => r.avg != null).map((r) {
      final t = DateTime.fromMillisecondsSinceEpoch(r.dayUtc, isUtc: true);
      final v = showLb ? r.avg! * 2.20462 : r.avg!;
      return HealthPoint(t, v);
    }).toList();
  }

  (DateTime?, DateTime?) _rangeFor(HealthTimeframe tf) {
    final now = DateTime.now();
    switch (tf) {
      case HealthTimeframe.day:
        return (DateTime(now.year, now.month, now.day), now);
      case HealthTimeframe.week:
        final mon = now.subtract(Duration(days: now.weekday - 1));
        return (DateTime(mon.year, mon.month, mon.day), now);
      case HealthTimeframe.month:
        return (DateTime(now.year, now.month, 1), now);
      case HealthTimeframe.year:
        return (DateTime(now.year, 1, 1), now);
      case HealthTimeframe.all:
        return (null, null);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              SegmentedButton<bool>(
                segments: const [
                  ButtonSegment(value: false, label: Text('kg')),
                  ButtonSegment(value: true, label: Text('lb')),
                ],
                selected: {showLb},
                onSelectionChanged: (s) => setState(() => showLb = s.first),
                style: const ButtonStyle(visualDensity: VisualDensity.compact),
              ),
            ],
          ),
        ),
        Expanded(
          child: FutureBuilder<List<HealthPoint>>(
            future: _load(),
            builder: (ctx, snap) {
              if (snap.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              final points = snap.data ?? const [];
              return RefreshIndicator(
                onRefresh: () async {
                  final repo = context.read<MetricsRepository>();
                  await SyncBootstrap.ensure(
                    db: repo.db,
                    repo: repo,
                    platform:
                        Theme.of(context).platform == TargetPlatform.iOS
                            ? 'ios'
                            : 'android',
                  ).manualSync(full: false);
                  setState(() {});
                },
                child: ListView(
                  padding: EdgeInsets.zero,
                  children: [
                    HealthTimelineChart(
                      series: [
                        HealthSeries(
                          id: 'weight',
                          points: points,
                          smooth: true,
                          showDots: false,
                          fillBelow: true,
                        ),
                      ],
                      timeframe: timeframe,
                      onFrame: (tf) => setState(() => timeframe = tf),
                      onSelect: (_) => setState(() {}),
                      valueLabel: (y) => showLb
                          ? '${y.toStringAsFixed(1)} lb'
                          : '${y.toStringAsFixed(1)} kg',
                      dateLabel: (t) => '${t.month}/${t.day}',
                    ),
                    if (points.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                        child: _statsRow(points),
                      ),
                    if (points.isEmpty)
                      const Padding(
                        padding: EdgeInsets.all(32),
                        child: Center(
                          child: Text(
                            'No weight data yet.\nSync from Apple Health or add data manually.',
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _statsRow(List<HealthPoint> pts) {
    final latest = pts.last.y;
    final avg = pts.map((e) => e.y).fold(0.0, (a, b) => a + b) / pts.length;
    final min = pts.map((e) => e.y).reduce((a, b) => a < b ? a : b);
    final max = pts.map((e) => e.y).reduce((a, b) => a > b ? a : b);
    String fmt(double v) =>
        showLb ? '${v.toStringAsFixed(1)} lb' : '${v.toStringAsFixed(1)} kg';
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _statTile('Latest', fmt(latest)),
        _statTile('Avg', fmt(avg)),
        _statTile('Min', fmt(min)),
        _statTile('Max', fmt(max)),
      ],
    );
  }

  Widget _statTile(String label, String value) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        label,
        style: TextStyle(
          color: Theme.of(context).colorScheme.onSurfaceVariant,
          fontSize: 12,
        ),
      ),
      const SizedBox(height: 2),
      Text(value, style: const TextStyle(fontWeight: FontWeight.w600)),
    ],
  );
}
