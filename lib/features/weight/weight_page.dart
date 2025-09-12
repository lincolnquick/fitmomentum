import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:fitmomentum/shared/repo/metrics_repository.dart';
import 'package:fitmomentum/shared/widgets/health_timeline_chart.dart';
import 'package:fitmomentum/shared/metrics/enums.dart';
import 'package:fitmomentum/shared/sync/sync_bootstrap.dart';

/// A basic Weight page that visualizes daily weight using the reusable chart.
/// - Pulls data from Drift via MetricsRepository
/// - Lets user switch Day/Week/Month/Year/All
/// - Formats values in kg or lb
class WeightPage extends StatefulWidget {
  const WeightPage({super.key});

  @override
  State<WeightPage> createState() => _WeightPageState();
}

class _WeightPageState extends State<WeightPage> {
  HealthTimeframe timeframe = HealthTimeframe.month;
  bool showLb = false;

  @override
  void initState() {
    super.initState();
    // Optionally kick a quick sync when opening the page (non-blocking)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final sync = SyncBootstrap.ensure(
        db: context.read<MetricsRepository>().db,
        repo: context.read<MetricsRepository>(),
        platform: Theme.of(context).platform == TargetPlatform.iOS
            ? 'ios'
            : 'android',
      );
      sync.manualSync(full: false);
    });
  }

  Future<List<HealthPoint>> _load(BuildContext context) async {
    final repo = context.read<MetricsRepository>();
    final range = _rangeFor(timeframe);
    final rows = await repo.getDailySeries(
      AggMetric.weightKg,
      from: range.$1,
      to: range.$2,
    );
    // Map DailyAggData -> HealthPoint (use avg for weight)
    return rows.where((r) => r.avg != null).map((r) {
      final tUtc = DateTime.fromMillisecondsSinceEpoch(r.dayUtc, isUtc: true);
      final vKg = r.avg!;
      final v = showLb ? (vKg * 2.20462) : vKg;
      return HealthPoint(tUtc, v);
    }).toList();
  }

  (DateTime?, DateTime?) _rangeFor(HealthTimeframe tf) {
    final now = DateTime.now();
    switch (tf) {
      case HealthTimeframe.day:
        final start = DateTime(now.year, now.month, now.day);
        return (start, now);
      case HealthTimeframe.week:
        final monday = now.subtract(Duration(days: now.weekday - 1));
        final start = DateTime(monday.year, monday.month, monday.day);
        return (start, now);
      case HealthTimeframe.month:
        final start = DateTime(now.year, now.month, 1);
        return (start, now);
      case HealthTimeframe.year:
        final start = DateTime(now.year, 1, 1);
        return (start, now);
      case HealthTimeframe.all:
        return (null, null);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Weight'),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: SegmentedButton<bool>(
              segments: const [
                ButtonSegment(value: false, label: Text('kg')),
                ButtonSegment(value: true, label: Text('lb')),
              ],
              selected: {showLb},
              onSelectionChanged: (s) => setState(() => showLb = s.first),
              style: ButtonStyle(visualDensity: VisualDensity.compact),
            ),
          ),
        ],
      ),
      body: FutureBuilder<List<HealthPoint>>(
        future: _load(context),
        builder: (context, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          final points = snap.data ?? const [];

          return RefreshIndicator(
            onRefresh: () async {
              final sync = SyncBootstrap.ensure(
                db: context.read<MetricsRepository>().db,
                repo: context.read<MetricsRepository>(),
                platform: Theme.of(context).platform == TargetPlatform.iOS
                    ? 'ios'
                    : 'android',
              );
              await sync.manualSync(full: false);
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
                  onSelect: (sp) {
                    // optionally show a bottom sheet or tooltip; here we just rebuild to update the selection pill
                    setState(() {});
                  },
                  valueLabel: (y) => showLb
                      ? '${y.toStringAsFixed(1)} lb'
                      : '${y.toStringAsFixed(1)} kg',
                  dateLabel: (t) => '${t.month}/${t.day}',
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                  child: _statsRow(points),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _statsRow(List<HealthPoint> pts) {
    if (pts.isEmpty) return const SizedBox.shrink();
    final latest = pts.last.y;
    final avg =
        pts.map((e) => e.y).fold<double>(0, (a, b) => a + b) / pts.length;
    final min = pts.map((e) => e.y).reduce((a, b) => a < b ? a : b);
    final max = pts.map((e) => e.y).reduce((a, b) => a > b ? a : b);
    String f(double v) =>
        showLb ? '${v.toStringAsFixed(1)} lb' : '${v.toStringAsFixed(1)} kg';

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _statTile('Latest', f(latest)),
        _statTile('Avg', f(avg)),
        _statTile('Min', f(min)),
        _statTile('Max', f(max)),
      ],
    );
  }

  Widget _statTile(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
        ),
      ],
    );
  }
}
