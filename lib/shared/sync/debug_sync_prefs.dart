import 'package:shared_preferences/shared_preferences.dart';

/// DebugSyncPrefs – simple wrapper to tweak sync behavior at runtime.
/// Set these via a quick dev UI or from Dart DevTools.
class DebugSyncPrefs {
  static const _kWindowDays = 'health.debug.window_days'; // overrides delta
  static const _kFullDays = 'health.debug.full_window_days'; // overrides full
  static const _kLimitTypes =
      'health.debug.limit_types'; // if true, fetch fewer types
  static const _kVerboseLogs = 'health.debug.verbose_logs'; // verbose logging

  final SharedPreferences prefs;

  DebugSyncPrefs(this.prefs);

  int? get windowDays => prefs.getInt(_kWindowDays);
  int? get fullWindowDays => prefs.getInt(_kFullDays);
  bool get limitTypes => prefs.getBool(_kLimitTypes) ?? false;
  bool get verbose => prefs.getBool(_kVerboseLogs) ?? false;

  Future<void> setWindowDays(int? v) async {
    if (v == null) {
      await prefs.remove(_kWindowDays);
    } else {
      await prefs.setInt(_kWindowDays, v);
    }
  }

  Future<void> setFullWindowDays(int? v) async {
    if (v == null) {
      await prefs.remove(_kFullDays);
    } else {
      await prefs.setInt(_kFullDays, v);
    }
  }

  Future<void> setLimitTypes(bool v) async => prefs.setBool(_kLimitTypes, v);
  Future<void> setVerbose(bool v) async => prefs.setBool(_kVerboseLogs, v);
}
