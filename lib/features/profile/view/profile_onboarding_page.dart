import 'package:fitmomentum/shared/repo/metrics_repository.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/health/health_service.dart';

class ProfileOnboardingPage extends StatefulWidget {
  const ProfileOnboardingPage({super.key, this.onFinishedRoute = '/metrics'});

  final String onFinishedRoute;

  @override
  State<ProfileOnboardingPage> createState() => _ProfileOnboardingPageState();
}

class _ProfileOnboardingPageState extends State<ProfileOnboardingPage> {
  bool _busy = false;
  String? _error;
  final _service = HealthService();

  @override
  void initState() {
    super.initState();
    _service.configure();
  }

  Future<void> _connectHealth() async {
    final repo = context.read<MetricsRepository>();
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      final ok = await _service.requestAuthorization();
      if (!ok) {
        throw Exception(
          'Health permissions not granted. You can adjust in Settings → Health → Data Access & Devices.',
        );
      }
      final snap = await _service.readUser();

      await repo.upsertUserCharacteristics(
        dateOfBirth: snap.dateOfBirth,
        sex: snap.sex,
        heightMeters: snap.heightMeters,
        weightKg: snap.weightKg,
        capturedAt: snap.capturedAt,
      );

      if (!mounted) return;
      Navigator.of(context).pushNamedAndRemoveUntil(
        widget.onFinishedRoute,
        (route) => route.isFirst,
      );
    } catch (e) {
      setState(() {
        _error = e.toString();
      });
    } finally {
      setState(() {
        _busy = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Set up your profile')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 480),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  "Connect to Apple Health to import your Date of Birth (for age), Sex, Height, and most recent Weight.",
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                if (_error != null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Text(
                      _error!,
                      style: const TextStyle(color: Colors.red),
                    ),
                  ),
                FilledButton.icon(
                  icon: const Icon(Icons.favorite),
                  onPressed: _busy ? null : _connectHealth,
                  label: _busy
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Connect Apple Health'),
                ),
                const SizedBox(height: 12),
                const Text(
                  "Tip: If you deny a permission, you can change it later in the Health app under Data Access & Devices.",
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
