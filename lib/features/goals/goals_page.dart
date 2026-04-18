import 'package:fitmomentum/shared/db/app_database.dart';
import 'package:fitmomentum/shared/db/user_characteristic_extensions.dart';
import 'package:fitmomentum/shared/repo/metrics_repository.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class GoalsPage extends StatefulWidget {
  const GoalsPage({super.key});

  @override
  State<GoalsPage> createState() => _GoalsPageState();
}

class _GoalsPageState extends State<GoalsPage> {
  // Placeholder goal inputs (not yet persisted)
  final _goalWeightController = TextEditingController();
  bool _showLb = true;
  String _activityLevel = 'sedentary';
  String _macroPreset = 'balanced';

  @override
  void dispose() {
    _goalWeightController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final repo = context.watch<MetricsRepository>();
    return Scaffold(
      appBar: AppBar(title: const Text('Goals')),
      body: StreamBuilder<UserCharacteristic?>(
        stream: repo.watchUserCharacteristics(),
        builder: (ctx, snapshot) {
          final uc = snapshot.data;
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _goalInputCard(context),
              const SizedBox(height: 12),
              _bodyMetricsCard(context, uc),
              const SizedBox(height: 12),
              _tdeeCard(context, uc),
              const SizedBox(height: 12),
              _macroCard(context),
              const SizedBox(height: 12),
              _predictionCard(context),
            ],
          );
        },
      ),
    );
  }

  Widget _goalInputCard(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('My Goal', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _goalWeightController,
                    decoration: InputDecoration(
                      labelText: 'Target Weight',
                      hintText: _showLb ? 'e.g., 160.0' : 'e.g., 72.5',
                      border: const OutlineInputBorder(),
                      suffixText: _showLb ? 'lb' : 'kg',
                    ),
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  ),
                ),
                const SizedBox(width: 12),
                SegmentedButton<bool>(
                  segments: const [
                    ButtonSegment(value: true, label: Text('lb')),
                    ButtonSegment(value: false, label: Text('kg')),
                  ],
                  selected: {_showLb},
                  onSelectionChanged: (s) => setState(() => _showLb = s.first),
                  style: const ButtonStyle(visualDensity: VisualDensity.compact),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    icon: const Icon(Icons.calendar_today, size: 18),
                    label: const Text('Set Target Date'),
                    onPressed: () async {
                      await showDatePicker(
                        context: context,
                        initialDate: DateTime.now().add(const Duration(days: 90)),
                        firstDate: DateTime.now().add(const Duration(days: 1)),
                        lastDate: DateTime.now().add(const Duration(days: 3650)),
                      );
                      // TODO: persist target date
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: FilledButton.icon(
                    icon: const Icon(Icons.flag, size: 18),
                    label: const Text('Save Goal'),
                    onPressed: () {
                      // TODO: persist goal weight
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Goal saving coming soon!')),
                      );
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            _infoRow(
              context,
              Icons.info_outline,
              'Safe weight loss is 0.5–1 kg (1–2 lb) per week.',
            ),
          ],
        ),
      ),
    );
  }

  Widget _bodyMetricsCard(BuildContext context, UserCharacteristic? uc) {
    final bmiStr = _calcBmi(uc);
    final bmrStr = _calcBmr(uc);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Body Metrics', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(child: _metricTile(context, 'BMI', bmiStr, _bmiCategory(uc))),
                Expanded(child: _metricTile(context, 'BMR', bmrStr, 'kcal/day')),
              ],
            ),
            if (uc == null)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: _infoRow(
                  context,
                  Icons.person_outline,
                  'Complete your profile to see calculations.',
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _tdeeCard(BuildContext context, UserCharacteristic? uc) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Daily Energy (TDEE)', style: Theme.of(context).textTheme.titleMedium),
                _calcTdee(uc) != null
                    ? Text(
                        '${_calcTdee(uc)!.round()} kcal',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: Theme.of(context).colorScheme.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      )
                    : const Text('--'),
              ],
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              initialValue: _activityLevel,
              decoration: const InputDecoration(
                labelText: 'Activity Level',
                border: OutlineInputBorder(),
              ),
              items: const [
                DropdownMenuItem(value: 'sedentary', child: Text('Sedentary (desk job)')),
                DropdownMenuItem(value: 'light', child: Text('Lightly active (1–3 days/wk)')),
                DropdownMenuItem(value: 'moderate', child: Text('Moderately active (3–5 days/wk)')),
                DropdownMenuItem(value: 'active', child: Text('Very active (6–7 days/wk)')),
                DropdownMenuItem(value: 'extra', child: Text('Extra active (physical job)')),
              ],
              onChanged: (v) => setState(() => _activityLevel = v ?? 'sedentary'),
            ),
            const SizedBox(height: 8),
            _infoRow(context, Icons.science_outlined, 'Uses Mifflin-St Jeor formula.'),
          ],
        ),
      ),
    );
  }

  Widget _macroCard(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Macro Recommendation', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 12),
            SegmentedButton<String>(
              segments: const [
                ButtonSegment(value: 'highProtein', label: Text('High Protein')),
                ButtonSegment(value: 'lowCarb', label: Text('Low Carb')),
                ButtonSegment(value: 'balanced', label: Text('Balanced')),
              ],
              selected: {_macroPreset},
              onSelectionChanged: (s) => setState(() => _macroPreset = s.first),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: _macroTargets().entries.map((e) => Column(
                children: [
                  Text(
                    e.value,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    e.key,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              )).toList(),
            ),
            const SizedBox(height: 8),
            _infoRow(context, Icons.info_outline, 'Targets based on TDEE and goal rate.'),
          ],
        ),
      ),
    );
  }

  Widget _predictionCard(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Prediction', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 12),
            _predictionRow(context, 'Estimated goal date', '--'),
            const Divider(height: 20),
            _predictionRow(context, 'At current trend (7d)', '--'),
            _predictionRow(context, 'At current trend (30d)', '--'),
            _predictionRow(context, 'At current trend (90d)', '--'),
            const SizedBox(height: 8),
            _infoRow(
              context,
              Icons.auto_graph,
              'Predictions require weight history and a set goal.',
            ),
          ],
        ),
      ),
    );
  }

  Widget _predictionRow(BuildContext context, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }

  Widget _metricTile(
      BuildContext context, String label, String value, String sub) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
        Text(
          value,
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          sub,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }

  Widget _infoRow(BuildContext context, IconData icon, String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 14, color: Theme.of(context).colorScheme.onSurfaceVariant),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            text,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ),
      ],
    );
  }

  // ── Calculations (Mifflin-St Jeor) ──────────────────────────────────────

  String _calcBmi(UserCharacteristic? uc) {
    if (uc?.weightKg == null || uc?.heightMeters == null) return '--';
    final h = uc!.heightMeters!;
    if (h <= 0) return '--';
    return (uc.weightKg! / (h * h)).toStringAsFixed(1);
  }

  String _bmiCategory(UserCharacteristic? uc) {
    if (uc?.weightKg == null || uc?.heightMeters == null) return '';
    final h = uc!.heightMeters!;
    if (h <= 0) return '';
    final bmi = uc.weightKg! / (h * h);
    if (bmi < 18.5) return 'Underweight';
    if (bmi < 25.0) return 'Healthy';
    if (bmi < 30.0) return 'Overweight';
    return 'Obese';
  }

  String _calcBmr(UserCharacteristic? uc) {
    final bmr = _bmrValue(uc);
    return bmr != null ? '${bmr.round()}' : '--';
  }

  double? _bmrValue(UserCharacteristic? uc) {
    if (uc?.weightKg == null || uc?.heightMeters == null || uc?.dateOfBirth == null) {
      return null;
    }
    final w = uc!.weightKg!;
    final h = uc.heightMeters! * 100; // cm
    final a = uc.ageYears;
    // Mifflin-St Jeor
    if (uc.sex == 'male') return 10 * w + 6.25 * h - 5 * a + 5;
    if (uc.sex == 'female') return 10 * w + 6.25 * h - 5 * a - 161;
    // Unknown sex: average of male/female
    return (10 * w + 6.25 * h - 5 * a + 5 + 10 * w + 6.25 * h - 5 * a - 161) / 2;
  }

  double? _calcTdee(UserCharacteristic? uc) {
    final bmr = _bmrValue(uc);
    if (bmr == null) return null;
    const factors = {
      'sedentary': 1.2,
      'light': 1.375,
      'moderate': 1.55,
      'active': 1.725,
      'extra': 1.9,
    };
    return bmr * (factors[_activityLevel] ?? 1.2);
  }

  Map<String, String> _macroTargets() {
    switch (_macroPreset) {
      case 'highProtein':
        return {'Protein': '40%', 'Carbs': '30%', 'Fat': '30%'};
      case 'lowCarb':
        return {'Protein': '35%', 'Carbs': '20%', 'Fat': '45%'};
      default:
        return {'Protein': '30%', 'Carbs': '40%', 'Fat': '30%'};
    }
  }
}
