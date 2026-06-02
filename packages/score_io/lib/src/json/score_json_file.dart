import 'dart:convert';
import 'dart:io';

import 'package:score_core/score_core.dart';

import 'schema_migrator.dart';
import 'score_serializer.dart';

/// Reads and writes [Score] values to `.score.json` files.
final class ScoreJsonFile {
  ScoreJsonFile._();

  static const _serializer = ScoreSerializer();
  static const _migrator = SchemaMigrator();

  static Future<void> save(Score score, String path) async {
    final json = _serializer.toJson(score);
    await File(path).writeAsString(json, encoding: utf8);
  }

  static Future<Score> load(String path) async {
    final file = File(path);
    if (!file.existsSync()) {
      throw ScoreException('File not found: $path');
    }
    try {
      final content = await file.readAsString(encoding: utf8);
      final raw = jsonDecode(content) as Map<String, Object?>;
      final migrated = _migrator.migrate(raw);
      return _serializer.fromMap(migrated);
    } on ScoreException {
      rethrow;
    } catch (e) {
      throw ScoreException('Failed to load score from $path', cause: e);
    }
  }
}
