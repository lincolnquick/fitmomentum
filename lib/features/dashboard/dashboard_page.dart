import 'dart:math' as math;
import 'package:fitmomentum/shared/db/app_database.dart';
import 'package:fitmomentum/shared/db/user_characteristic_extensions.dart';
import 'package:fitmomentum/shared/repo/metrics_repository.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  final _checklist = [false, false, false];
  bool _bannerDismissed = false;

  @override
  Widget build(BuildContext context) {
    final repo = context.watch<MetricsRepository>();
    return Scaffold(
      appBar: AppBar(title: const Text('FitMomentum')),
      body: StreamBuilder<UserCharacteristic?>(
        stream: repo.watchUserCharacteristics(),
        builder: (ctx, snapshot) {
          final uc = snapshot.data;
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              if (uc == null) _setupBanner(context),
              if (uc == null) const SizedBox(height: 16),
              _progressArcCard(context, uc),
              const SizedBox(height: 12),
              if (!_bannerDismissed) _motivationalCard(context),
              if (!_bannerDismissed) const SizedBox(height: 12),
              _checklistCard(context),
              const SizedBox(height: 12),
              _quickStatsCard(context, uc),
            ],
          );
        },
      ),
    );
  }

  Widget _setupBanner(BuildContext context) {
    return Card(
      color: Theme.of(context).colorScheme.errorContainer,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Icon(
              Icons.person_add_outlined,
              color: Theme.of(context).colorScheme.onErrorContainer,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'Set up your profile to get started.',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onErrorContainer,
                ),
              ),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pushNamed('/profile'),
              child: const Text('Set Up'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _progressArcCard(BuildContext context, UserCharacteristic? uc) {
    final weightStr = uc?.weightLb != null
        ? '${uc!.weightLb!.toStringAsFixed(1)} lb'
        : '--';
    return Card(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
        child: Column(
          children: [
            SizedBox(
              height: 140,
              width: double.infinity,
              child: CustomPaint(
                painter: _ArcPainter(
                  progress: 0.30,
                  color: Theme.of(context).colorScheme.primary,
                  trackColor: Theme.of(context).colorScheme.surfaceContainerHighest,
                ),
                child: Align(
                  alignment: Alignment.bottomCenter,
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          weightStr,
                          style: Theme.of(context).textTheme.headlineMedium
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        Text(
                          'Current Weight',
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(
                                color: Theme.of(context)
                                    .colorScheme
                                    .onSurfaceVariant,
                              ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Set a goal in the Goals tab to track your progress',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _motivationalCard(BuildContext context) {
    return Card(
      color: Theme.of(context).colorScheme.primaryContainer,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Icon(
              Icons.wb_sunny_outlined,
              color: Theme.of(context).colorScheme.onPrimaryContainer,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'Every healthy choice adds up. Keep going!',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onPrimaryContainer,
                ),
              ),
            ),
            IconButton(
              icon: Icon(
                Icons.close,
                size: 18,
                color: Theme.of(context).colorScheme.onPrimaryContainer,
              ),
              onPressed: () => setState(() => _bannerDismissed = true),
              visualDensity: VisualDensity.compact,
            ),
          ],
        ),
      ),
    );
  }

  Widget _checklistCard(BuildContext context) {
    const tasks = ['Log weight', 'Log meals', 'Hit step goal'];
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 8, 8, 0),
              child: Row(
                children: [
                  Text(
                    "Today's Checklist",
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const Spacer(),
                  if (_checklist.every((c) => c))
                    const Icon(Icons.check_circle, color: Colors.green, size: 20),
                ],
              ),
            ),
            for (int i = 0; i < tasks.length; i++)
              CheckboxListTile(
                title: Text(tasks[i]),
                value: _checklist[i],
                onChanged: (v) => setState(() => _checklist[i] = v ?? false),
                dense: true,
                shape: const RoundedRectangleBorder(),
              ),
          ],
        ),
      ),
    );
  }

  Widget _quickStatsCard(BuildContext context, UserCharacteristic? uc) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Quick Stats', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _statTile(context, 'BMI', '--'),
                _statTile(context, 'BMR', '--'),
                _statTile(context, 'TDEE', '--'),
              ],
            ),
            const SizedBox(height: 8),
            Center(
              child: Text(
                'Fill in your profile and goals to unlock calculations',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _statTile(BuildContext context, String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}

class _ArcPainter extends CustomPainter {
  final double progress; // 0.0 – 1.0
  final Color color;
  final Color trackColor;

  const _ArcPainter({
    required this.progress,
    required this.color,
    required this.trackColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height;
    final rx = size.width / 2 - 16;
    final ry = size.height - 16;
    final rect = Rect.fromCenter(
      center: Offset(cx, cy),
      width: rx * 2,
      height: ry * 2,
    );

    final trackPaint = Paint()
      ..color = trackColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 16
      ..strokeCap = StrokeCap.round;

    final progressPaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 16
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(rect, math.pi, math.pi, false, trackPaint);
    if (progress > 0) {
      canvas.drawArc(rect, math.pi, math.pi * progress.clamp(0.0, 1.0), false, progressPaint);
    }
  }

  @override
  bool shouldRepaint(_ArcPainter old) =>
      old.progress != progress || old.color != color;
}
