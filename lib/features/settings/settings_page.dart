import 'package:fitmomentum/shared/db/app_database.dart';
import 'package:fitmomentum/shared/db/user_characteristic_extensions.dart';
import 'package:fitmomentum/shared/repo/metrics_repository.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool _notificationsEnabled = false;
  bool _biometricEnabled = false;
  bool _useLb = true;

  @override
  Widget build(BuildContext context) {
    final repo = context.watch<MetricsRepository>();
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: StreamBuilder<UserCharacteristic?>(
        stream: repo.watchUserCharacteristics(),
        builder: (ctx, snapshot) {
          final uc = snapshot.data;
          return ListView(
            children: [
              _sectionHeader(context, 'Profile'),
              _profileTile(context, uc),
              _divider(),
              _sectionHeader(context, 'Units'),
              SwitchListTile(
                title: const Text('Use pounds (lb)'),
                subtitle: const Text('Show weight in lb instead of kg'),
                value: _useLb,
                onChanged: (v) => setState(() => _useLb = v),
              ),
              _divider(),
              _sectionHeader(context, 'Notifications'),
              SwitchListTile(
                title: const Text('Daily Reminders'),
                subtitle: const Text('Remind me to log weight and meals'),
                value: _notificationsEnabled,
                onChanged: (v) => setState(() => _notificationsEnabled = v),
              ),
              if (_notificationsEnabled)
                ListTile(
                  leading: const Icon(Icons.access_time),
                  title: const Text('Reminder Time'),
                  trailing: const Text('8:00 AM'),
                  onTap: () => _showComingSoon(context, 'Notification time picker'),
                ),
              _divider(),
              _sectionHeader(context, 'Privacy & Security'),
              SwitchListTile(
                title: const Text('Biometric Lock'),
                subtitle: const Text('Require Face ID or Touch ID to open app'),
                value: _biometricEnabled,
                onChanged: (v) => setState(() => _biometricEnabled = v),
              ),
              _divider(),
              _sectionHeader(context, 'Data'),
              ListTile(
                leading: const Icon(Icons.upload_file),
                title: const Text('Export Data'),
                subtitle: const Text('Download your data as CSV'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => _showComingSoon(context, 'Data export'),
              ),
              ListTile(
                leading: const Icon(Icons.sync),
                title: const Text('Sync with Apple Health'),
                subtitle: const Text('Re-sync all data from HealthKit'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => _showComingSoon(context, 'Manual full sync'),
              ),
              _divider(),
              _sectionHeader(context, 'About'),
              ListTile(
                leading: const Icon(Icons.info_outline),
                title: const Text('Version'),
                trailing: const Text('1.0.0', style: TextStyle(color: Colors.grey)),
              ),
              ListTile(
                leading: const Icon(Icons.privacy_tip_outlined),
                title: const Text('Privacy Policy'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => _showComingSoon(context, 'Privacy policy'),
              ),
              const SizedBox(height: 32),
            ],
          );
        },
      ),
    );
  }

  Widget _sectionHeader(BuildContext context, String title) => Padding(
    padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
    child: Text(
      title.toUpperCase(),
      style: Theme.of(context).textTheme.labelSmall?.copyWith(
        color: Theme.of(context).colorScheme.primary,
        fontWeight: FontWeight.bold,
        letterSpacing: 1.1,
      ),
    ),
  );

  Widget _divider() => const Divider(height: 1, indent: 16, endIndent: 16);

  Widget _profileTile(BuildContext context, UserCharacteristic? uc) {
    final subtitle = uc != null
        ? [
            if (uc.sex.isNotEmpty && uc.sex != 'unknown') uc.sex,
            if (uc.dateOfBirth != null) 'Age ${uc.ageYearsLabel}',
            if (uc.heightMeters != null) uc.heightLabel,
          ].join(' · ')
        : 'Not set up yet';

    return ListTile(
      leading: CircleAvatar(
        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
        child: Icon(
          Icons.person,
          color: Theme.of(context).colorScheme.onPrimaryContainer,
        ),
      ),
      title: Text(uc != null ? 'Profile' : 'Set Up Profile'),
      subtitle: Text(subtitle),
      trailing: const Icon(Icons.chevron_right),
      onTap: () => Navigator.of(context).pushNamed('/profile'),
    );
  }

  void _showComingSoon(BuildContext context, String feature) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('$feature coming soon!')),
    );
  }
}
