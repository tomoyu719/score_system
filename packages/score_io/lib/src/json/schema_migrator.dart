import 'package:score_core/score_core.dart';

/// Migrates raw JSON maps from older schema versions to the current version.
final class SchemaMigrator {
  const SchemaMigrator();

  static const int currentVersion = 1;

  Map<String, Object?> migrate(Map<String, Object?> data) {
    final version = data[r'$schema_version'] as int? ?? 0;
    if (version > currentVersion) {
      throw ScoreException('Unknown schema version $version');
    }
    return data;
  }
}
