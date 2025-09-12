import 'package:fitmomentum/shared/db/app_database.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:fitmomentum/shared/db/user_characteristic_extensions.dart';
import 'package:fitmomentum/shared/repo/metrics_repository.dart';
import 'package:fitmomentum/shared/sync/sync_bootstrap.dart';

class MetricsPage extends StatefulWidget {
  const MetricsPage({super.key});

  @override
  State<MetricsPage> createState() => _MetricsPageState();
}

class _MetricsPageState extends State<MetricsPage> {
  @override
  void initState() {
    super.initState();
    // Optional: small non-blocking sync when the page opens
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final repo = context.read<MetricsRepository>();
      final sync = SyncBootstrap.ensure(
        db: repo.db,
        repo: repo,
        platform: Theme.of(context).platform == TargetPlatform.iOS
            ? 'ios'
            : 'android',
      );
      sync.manualSync(full: false);
    });
  }

  Future<void> _refresh() async {
    final repo = context.read<MetricsRepository>();
    final sync = SyncBootstrap.ensure(
      db: repo.db,
      repo: repo,
      platform: Theme.of(context).platform == TargetPlatform.iOS
          ? 'ios'
          : 'android',
    );
    await sync.manualSync(full: false);
    // StreamBuilder below will rebuild automatically when DB changes,
    // but this ensures immediate visual feedback if needed.
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final repo = context.watch<MetricsRepository>();
    return Scaffold(
      appBar: AppBar(
        title: const Text('Metrics'),
        actions: [
          IconButton(
            tooltip: 'Sync',
            icon: const Icon(Icons.sync),
            onPressed: _refresh,
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _refresh,
        child: StreamBuilder<UserCharacteristic?>(
          stream: repo.watchUserCharacteristics(),
          builder: (context, snapshot) {
            final uc = snapshot.data;
            final heightCm = (uc?.heightMeters != null)
                ? (uc!.heightMeters! * 100).toStringAsFixed(1)
                : '—';
            final weightLb = (uc?.weightKg != null)
                ? (uc!.weightKg! * 2.20462).toStringAsFixed(1)
                : '—';

            return ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _row('Age', uc?.ageYearsLabel ?? '—'),
                _row('Sex', (uc?.sex.isNotEmpty ?? false) ? uc!.sex : '—'),
                _row(
                  'Date of Birth',
                  uc?.dateOfBirth != null
                      ? uc!.dateOfBirth!
                            .toLocal()
                            .toIso8601String()
                            .split('T')
                            .first
                      : '—',
                ),
                _row('Height', heightCm != '—' ? '$heightCm cm' : '—'),
                _row('Weight', weightLb != '—' ? '$weightLb lb' : '—'),
                const SizedBox(height: 12),
                if (uc == null)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Not connected yet.',
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 8),
                      FilledButton.icon(
                        icon: const Icon(Icons.person_add),
                        label: const Text('Set up Profile'),
                        onPressed: () =>
                            Navigator.of(context).pushNamed('/profile'),
                      ),
                    ],
                  ),
              ],
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        icon: const Icon(Icons.edit),
        label: const Text('Edit'),
        onPressed: () => _openEditSheet(context),
      ),
    );
  }
}

Widget _row(String label, String value) => Padding(
  padding: const EdgeInsets.symmetric(vertical: 8),
  child: Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      Text(label),
      Text(value, style: const TextStyle(fontWeight: FontWeight.w600)),
    ],
  ),
);

void _openEditSheet(BuildContext context) {
  final repo = context.read<MetricsRepository>();

  // Load current row once for initial form values
  // (no await in showModalBottomSheet builder; keep it simple by using a FutureBuilder inside if needed)
  repo.getUserCharacteristics().then((existing) {
    final formKey = GlobalKey<FormState>();
    final sex = ValueNotifier<String>(
      (existing?.sex.isEmpty ?? true) ? 'unknown' : existing!.sex,
    );

    final dobTextController = TextEditingController(
      text: existing?.dateOfBirth != null
          ? existing!.dateOfBirth!.toLocal().toIso8601String().split('T').first
          : '',
    );

    final heightCmController = TextEditingController(
      text: existing?.heightCm != null
          ? existing!.heightCm!.toStringAsFixed(1)
          : '',
    );

    final weightLbController = TextEditingController(
      text: existing?.weightLb != null
          ? existing!.weightLb!.toStringAsFixed(1)
          : '',
    );

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (ctx) {
        return Padding(
          padding: EdgeInsets.only(
            left: 16,
            right: 16,
            top: 16,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 16,
          ),
          child: Form(
            key: formKey,
            child: ListView(
              shrinkWrap: true,
              children: [
                Row(
                  children: [
                    const Icon(Icons.tune),
                    const SizedBox(width: 8),
                    Text(
                      'Edit Metrics',
                      style: Theme.of(ctx).textTheme.titleLarge,
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Sex
                ValueListenableBuilder<String>(
                  valueListenable: sex,
                  builder: (context, value, _) {
                    return DropdownButtonFormField<String>(
                      initialValue: value,
                      decoration: const InputDecoration(
                        labelText: 'Sex',
                        border: OutlineInputBorder(),
                      ),
                      items: const [
                        DropdownMenuItem(
                          value: 'unknown',
                          child: Text('Unknown'),
                        ),
                        DropdownMenuItem(value: 'male', child: Text('Male')),
                        DropdownMenuItem(
                          value: 'female',
                          child: Text('Female'),
                        ),
                        DropdownMenuItem(value: 'other', child: Text('Other')),
                      ],
                      onChanged: (v) {
                        if (v != null) sex.value = v;
                      },
                    );
                  },
                ),
                const SizedBox(height: 12),

                // Date of Birth
                TextFormField(
                  controller: dobTextController,
                  readOnly: true,
                  decoration: InputDecoration(
                    labelText: 'Date of Birth',
                    hintText: 'YYYY-MM-DD',
                    border: const OutlineInputBorder(),
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.calendar_today),
                      onPressed: () async {
                        final today = DateTime.now();
                        final initial =
                            existing?.dateOfBirth ??
                            DateTime(today.year - 25, today.month, today.day);
                        final picked = await showDatePicker(
                          context: ctx,
                          initialDate: initial,
                          firstDate: DateTime(1900),
                          lastDate: today,
                        );
                        if (picked != null) {
                          dobTextController.text = picked
                              .toLocal()
                              .toIso8601String()
                              .split('T')
                              .first;
                        }
                      },
                    ),
                    prefixIcon: (dobTextController.text.isNotEmpty)
                        ? IconButton(
                            tooltip: 'Clear',
                            icon: const Icon(Icons.clear),
                            onPressed: () => dobTextController.clear(),
                          )
                        : null,
                  ),
                ),
                const SizedBox(height: 12),

                // Height (cm)
                TextFormField(
                  controller: heightCmController,
                  decoration: const InputDecoration(
                    labelText: 'Height (cm)',
                    hintText: 'e.g., 175.5',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) return null; // optional
                    final d = double.tryParse(v);
                    if (d == null || d <= 0 || d > 300) {
                      return 'Enter a valid height in cm';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 12),

                // Weight (lb)
                TextFormField(
                  controller: weightLbController,
                  decoration: const InputDecoration(
                    labelText: 'Weight (lb)',
                    hintText: 'e.g., 180.2',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) return null; // optional
                    final d = double.tryParse(v);
                    if (d == null || d <= 0 || d > 1400) {
                      return 'Enter a valid weight in lb';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                Row(
                  children: [
                    OutlinedButton.icon(
                      icon: const Icon(Icons.close),
                      label: const Text('Cancel'),
                      onPressed: () => Navigator.of(ctx).pop(),
                    ),
                    const Spacer(),
                    FilledButton.icon(
                      icon: const Icon(Icons.save),
                      label: const Text('Save'),
                      onPressed: () async {
                        if (!formKey.currentState!.validate()) return;

                        // Parse inputs
                        DateTime? dob;
                        if (dobTextController.text.trim().isNotEmpty) {
                          try {
                            dob = DateTime.parse(
                              '${dobTextController.text.trim()}T00:00:00',
                            );
                          } catch (_) {
                            dob = null;
                          }
                        }

                        double? heightMeters;
                        final h = heightCmController.text.trim();
                        if (h.isNotEmpty) {
                          final cm = double.tryParse(h);
                          if (cm != null) heightMeters = cm / 100.0;
                        }

                        double? weightKg;
                        final w = weightLbController.text.trim();
                        if (w.isNotEmpty) {
                          final lb = double.tryParse(w);
                          if (lb != null) weightKg = lb / 2.20462;
                        }

                        await repo.upsertUserCharacteristics(
                          dateOfBirth: dobTextController.text.trim().isEmpty
                              ? null
                              : dob,
                          sex: sex.value,
                          heightMeters: heightMeters,
                          weightKg: weightKg,
                          capturedAt: DateTime.now().toUtc(),
                        );

                        if (ctx.mounted) Navigator.of(ctx).pop();
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  });
}
