import 'dart:io';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

/// Provides the location of the SQLite database file.
class AppPaths {
  static const _dbFileName = 'fitassist.db';

  /// Use Library directory on iOS (encrypted at rest while locked if NSFileProtectionComplete),
  /// AppDocuments on Android.
  static Future<String> dbPath() async {
    Directory base;
    if (Platform.isIOS || Platform.isMacOS) {
      base = await getLibraryDirectory();
    } else {
      base = await getApplicationDocumentsDirectory();
    }
    return p.join(base.path, _dbFileName);
  }
}
