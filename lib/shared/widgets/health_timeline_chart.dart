// Flutter reusable, Apple-Health–like timeline chart
// Dependencies:
//   fl_chart: ^0.68.0  // or latest
// Usage example is at bottom of this file.

import 'dart:math' as math;
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

/// Time window controls that mirror Apple Health: Daily/Weekly/Monthly/Yearly/All-Time.
enum HealthTimeframe { day, week, month, year, all }

/// Single data point (UTC DateTime + value).
class HealthPoint {
  final DateTime t;
  final double y;
  const HealthPoint(this.t, this.y);
}

/// Series definition (supports multiple metrics at once, e.g. net calories vs goal line).
class HealthSeries {
  final String id;
  final List<HealthPoint> points;
  final Color? color; // optional custom line color
  final bool dashed; // draw dashed line (for targets/predictions)
  final bool smooth; // cubic line (iOS feel)
  final bool showDots; // show dots on points
  final bool fillBelow; // subtle area fill
  const HealthSeries({
    required this.id,
    required this.points,
    this.color,
    this.dashed = false,
    this.smooth = true,
    this.showDots = false,
    this.fillBelow = false,
  });
}

/// Apple-Health–like timeline chart with:
/// • Segmented timeframe switcher (day/week/month/year/all)
/// • Horizontal scroll for long ranges
/// • Tap to select point with callback
/// • Responsive sizing
/// • Reusable across metrics (weight, calories, steps, etc.)
class HealthTimelineChart extends StatefulWidget {
  final List<HealthSeries> series; // one or more series
  final HealthTimeframe timeframe; // external selected timeframe
  final ValueChanged<HealthTimeframe>?
  onFrame; // called when user changes timeframe
  final ValueChanged<SelectedPoint>? onSelect; // called when user taps a point
  final String Function(double y)? valueLabel; // formats y for tooltip
  final String Function(DateTime t)? dateLabel; // formats date for tooltip/axis
  final double minHeight; // minimum chart height
  final EdgeInsetsGeometry padding; // outer padding
  final bool showGrid;
  final bool showFrameSelector;
  final int targetPointsPerScreen; // density: points across one screen width

  const HealthTimelineChart({
    super.key,
    required this.series,
    required this.timeframe,
    this.onFrame,
    this.onSelect,
    this.valueLabel,
    this.dateLabel,
    this.minHeight = 220,
    this.padding = const EdgeInsets.all(12),
    this.showGrid = true,
    this.showFrameSelector = true,
    this.targetPointsPerScreen = 24,
  });

  @override
  State<HealthTimelineChart> createState() => _HealthTimelineChartState();
}

class _HealthTimelineChartState extends State<HealthTimelineChart> {
  // Selection state (per active series index and spot index)
  SelectedPoint? _selection;

  final ScrollController _hScrollController = ScrollController();

  @override
  void dispose() {
    _hScrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Compute current time window
    final now = DateTime.now().toUtc();
    final start = _windowStart(now, widget.timeframe, widget.series);

    // Filter points per series to the current window
    final filtered = widget.series
        .map(
          (s) => HealthSeries(
            id: s.id,
            color: s.color,
            dashed: s.dashed,
            smooth: s.smooth,
            showDots: s.showDots,
            fillBelow: s.fillBelow,
            points: s.points
                .where(
                  (p) =>
                      p.t.isAfter(start) ||
                      widget.timeframe == HealthTimeframe.all,
                )
                .toList(),
          ),
        )
        .toList();

    // Compute a virtual width so the chart horizontally scrolls like Apple Health
    final totalPoints = filtered.fold<int>(
      0,
      (acc, s) => math.max(acc, s.points.length),
    );

    return Padding(
      padding: widget.padding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (widget.showFrameSelector)
            _FrameSelector(value: widget.timeframe, onChanged: widget.onFrame),
          const SizedBox(height: 8),
          LayoutBuilder(
            builder: (context, box) {
              // Choose width: at least the available width; expand for more points to enable scroll
              final pxPerPoint = math.max(
                8.0,
                box.maxWidth / widget.targetPointsPerScreen,
              );
              final contentWidth = math.max(
                box.maxWidth,
                totalPoints * pxPerPoint,
              );
              return SizedBox(
                height: math.max(widget.minHeight, box.maxWidth * 0.5),
                child: Scrollbar(
                  thumbVisibility: true,
                  controller: _hScrollController,
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    physics: const BouncingScrollPhysics(),
                    controller: _hScrollController,
                    child: ConstrainedBox(
                      constraints: BoxConstraints(minWidth: contentWidth),
                      child: _LineChartView(
                        series: filtered,
                        selection: _selection,
                        onSelect: (sp) {
                          setState(() => _selection = sp);
                          widget.onSelect?.call(sp);
                        },
                        valueLabel: widget.valueLabel,
                        dateLabel: widget.dateLabel,
                        showGrid: widget.showGrid,
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
          if (_selection != null) ...[
            const SizedBox(height: 8),
            _SelectionPill(
              selection: _selection!,
              valueLabel: widget.valueLabel,
              dateLabel: widget.dateLabel,
            ),
          ],
        ],
      ),
    );
  }

  DateTime _windowStart(
    DateTime nowUtc,
    HealthTimeframe tf,
    List<HealthSeries> series,
  ) {
    switch (tf) {
      case HealthTimeframe.day:
        return DateTime.utc(nowUtc.year, nowUtc.month, nowUtc.day);
      case HealthTimeframe.week:
        final monday = nowUtc.subtract(Duration(days: (nowUtc.weekday - 1)));
        return DateTime.utc(monday.year, monday.month, monday.day);
      case HealthTimeframe.month:
        return DateTime.utc(nowUtc.year, nowUtc.month, 1);
      case HealthTimeframe.year:
        return DateTime.utc(nowUtc.year, 1, 1);
      case HealthTimeframe.all:
        // Find earliest point across series
        DateTime earliest = nowUtc;
        for (final s in series) {
          for (final p in s.points) {
            if (p.t.isBefore(earliest)) earliest = p.t;
          }
        }
        return earliest.subtract(const Duration(days: 1));
    }
  }
}

/// Internal: the actual FLChart LineChart view
class _LineChartView extends StatelessWidget {
  final List<HealthSeries> series;
  final SelectedPoint? selection;
  final ValueChanged<SelectedPoint> onSelect;
  final String Function(double y)? valueLabel;
  final String Function(DateTime t)? dateLabel;
  final bool showGrid;

  const _LineChartView({
    required this.series,
    required this.selection,
    required this.onSelect,
    this.valueLabel,
    this.dateLabel,
    required this.showGrid,
  });

  @override
  Widget build(BuildContext context) {
    // Build combined domain (x) from all series for nice axis spacing
    final all = series.expand((s) => s.points).toList()
      ..sort((a, b) => a.t.compareTo(b.t));
    if (all.isEmpty) {
      return const Center(child: Text('No data'));
    }

    final minX = all.first.t.millisecondsSinceEpoch.toDouble();
    final maxX = all.last.t.millisecondsSinceEpoch.toDouble();
    double minY = double.infinity, maxY = -double.infinity;
    for (final s in series) {
      for (final p in s.points) {
        if (p.y.isNaN) continue;
        minY = math.min(minY, p.y);
        maxY = math.max(maxY, p.y);
      }
    }
    if (minY == double.infinity || maxY == -double.infinity) {
      minY = 0;
      maxY = 1; // fallback
    }
    if (minY == maxY) {
      // Expand a tiny bit for flat lines so we see a stroke
      minY -= 1;
      maxY += 1;
    }

    final theme = Theme.of(context);
    final gridColor = theme.colorScheme.outlineVariant.withValues(alpha: 0.5);

    // Map series → LineChartBarData
    final bars = <LineChartBarData>[];
    for (var i = 0; i < series.length; i++) {
      final s = series[i];
      final color = s.color ?? theme.colorScheme.primary;

      final spots = s.points
          .map((p) => FlSpot(p.t.millisecondsSinceEpoch.toDouble(), p.y))
          .toList();

      bars.add(
        LineChartBarData(
          spots: spots,
          isCurved: s.smooth,
          color: color,
          barWidth: 3,
          isStrokeCapRound: true,
          dotData: FlDotData(show: s.showDots),
          belowBarData: BarAreaData(
            show: s.fillBelow,
            gradient: LinearGradient(
              colors: [
                color.withValues(alpha: 0.20),
                color.withValues(alpha: 0.02),
              ],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          dashArray: s.dashed ? [6, 6] : null,
        ),
      );
    }

    return LineChart(
      LineChartData(
        minX: minX,
        maxX: maxX,
        minY: minY,
        maxY: maxY,
        clipData: const FlClipData.all(),
        backgroundColor: Colors.transparent,
        gridData: FlGridData(
          show: showGrid,
          horizontalInterval: (maxY - minY) / 4,
          drawVerticalLine: false,
          getDrawingHorizontalLine: (v) =>
              FlLine(color: gridColor, strokeWidth: 1),
        ),
        borderData: FlBorderData(show: false),
        titlesData: FlTitlesData(
          topTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          rightTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              reservedSize: 44,
              showTitles: true,
              interval: (maxY - minY) / 4,
              getTitlesWidget: (value, meta) {
                return Text(
                  valueLabel?.call(value) ?? value.toStringAsFixed(0),
                  style: TextStyle(
                    color: meta.axisSide == AxisSide.left
                        ? gridColor
                        : gridColor,
                  ),
                );
              },
            ),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 28,
              interval: ((maxX - minX) / 4).clamp(
                60 * 60 * 1000,
                double.infinity,
              ),
              getTitlesWidget: (value, meta) {
                final t = DateTime.fromMillisecondsSinceEpoch(
                  value.toInt(),
                  isUtc: true,
                ).toLocal();
                return Padding(
                  padding: const EdgeInsets.only(top: 6),
                  child: Text(
                    dateLabel?.call(t) ?? _defaultDateTick(t),
                    style: TextStyle(color: gridColor, fontSize: 12),
                  ),
                );
              },
            ),
          ),
        ),
        lineBarsData: bars,
        // Tap/press selection
        lineTouchData: LineTouchData(
          enabled: true,
          handleBuiltInTouches: false, // custom draw using [selection]
          touchCallback: (evt, resp) {
            if (resp == null ||
                resp.lineBarSpots == null ||
                resp.lineBarSpots!.isEmpty) {
              return;
            }

            final spot = resp.lineBarSpots!.first;
            final seriesIndex = bars.indexOf(spot.bar);
            final selected = SelectedPoint(
              seriesId: series[seriesIndex].id,
              seriesIndex: seriesIndex,
              t: DateTime.fromMillisecondsSinceEpoch(
                spot.x.toInt(),
                isUtc: true,
              ),
              y: spot.y,
            );
            onSelect(selected);
          },
          getTouchedSpotIndicator: (bar, indexes) {
            return indexes
                .map(
                  (_) => TouchedSpotIndicatorData(
                    FlLine(color: theme.colorScheme.primary, strokeWidth: 1),
                    FlDotData(show: true),
                  ),
                )
                .toList();
          },
          touchTooltipData: LineTouchTooltipData(
            // we draw our own pill; hide FLChart tooltip
            getTooltipItems: (_) => [],
          ),
        ),
      ),
    );
  }

  String _defaultDateTick(DateTime t) {
    // Simple, readable default
    final today = DateTime.now();
    final sameYear = t.year == today.year;
    if (sameYear) {
      return "${_mm(t.month)}/${_dd(t.day)}";
    }
    return "${_mm(t.month)}/${_dd(t.day)}/${t.year % 100}";
  }

  String _mm(int m) => m < 10 ? '0$m' : '$m';
  String _dd(int d) => d < 10 ? '0$d' : '$d';
}

/// Selected point model returned via [onSelect]
class SelectedPoint {
  final String seriesId;
  final int seriesIndex;
  final DateTime t; // UTC
  final double y;
  const SelectedPoint({
    required this.seriesId,
    required this.seriesIndex,
    required this.t,
    required this.y,
  });
}

/// Top segmented control for timeframe switching
class _FrameSelector extends StatelessWidget {
  final HealthTimeframe value;
  final ValueChanged<HealthTimeframe>? onChanged;
  const _FrameSelector({required this.value, this.onChanged});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final map = <HealthTimeframe, Widget>{
      HealthTimeframe.day: const Text('Day'),
      HealthTimeframe.week: const Text('Week'),
      HealthTimeframe.month: const Text('Month'),
      HealthTimeframe.year: const Text('Year'),
      HealthTimeframe.all: const Text('All'),
    };
    return CupertinoSegmentedControl<HealthTimeframe>(
      children: map,
      groupValue: value,
      onValueChanged: onChanged!,
      padding: const EdgeInsets.symmetric(horizontal: 4),
      selectedColor: theme.colorScheme.primary,
      unselectedColor: theme.colorScheme.surface,
      borderColor: theme.colorScheme.outlineVariant,
    );
  }
}

/// A material pill shown under the chart when a point is selected
class _SelectionPill extends StatelessWidget {
  final SelectedPoint selection;
  final String Function(double y)? valueLabel;
  final String Function(DateTime t)? dateLabel;
  const _SelectionPill({
    required this.selection,
    this.valueLabel,
    this.dateLabel,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final text =
        valueLabel?.call(selection.y) ?? selection.y.toStringAsFixed(1);
    final when =
        dateLabel?.call(selection.t.toLocal()) ?? "${selection.t.toLocal()}";
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: theme.colorScheme.outlineVariant),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: DefaultTextStyle(
        style: theme.textTheme.bodyMedium!,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.data_thresholding, size: 16),
            const SizedBox(width: 8),
            Text(text, style: const TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(width: 10),
            Text(
              when,
              style: TextStyle(color: theme.colorScheme.onSurfaceVariant),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Example usage (place in a demo screen)
// ---------------------------------------------------------------------------
/*
class ChartDemo extends StatefulWidget {
  const ChartDemo({super.key});
  @override
  State<ChartDemo> createState() => _ChartDemoState();
}

class _ChartDemoState extends State<ChartDemo> {
  HealthTimeframe tf = HealthTimeframe.month;
  SelectedPoint? last;

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now().toUtc();
    final pts = List.generate(120, (i) {
      final t = now.subtract(Duration(days: 119 - i));
      final v = 70 + math.sin(i / 8) * 2 + (math.Random(1).nextDouble() - 0.5);
      return HealthPoint(t, v);
    });

    return Scaffold(
      appBar: AppBar(title: const Text('Health Chart Demo')),
      body: HealthTimelineChart(
        series: [
          HealthSeries(id: 'weight', points: pts, color: Colors.blue, smooth: true, showDots: false),
        ],
        timeframe: tf,
        onFrame: (v) => setState(() => tf = v),
        onSelect: (sp) => setState(() => last = sp),
        valueLabel: (y) => "${y.toStringAsFixed(1)} kg",
        dateLabel: (t) => "${t.month}/${t.day}",
      ),
    );
  }
}
*/
