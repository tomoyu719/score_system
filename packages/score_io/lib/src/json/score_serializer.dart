import 'dart:convert';

import 'package:score_core/score_core.dart';

/// Serializes and deserializes [Score] to/from JSON maps and strings.
final class ScoreSerializer {
  const ScoreSerializer();

  static const _converter = ScoreJsonConverter();
  static const int schemaVersion = 1;

  Map<String, Object?> toMap(Score score) => {
        r'$schema_version': schemaVersion,
        ..._converter.scoreToMap(score),
      };

  Score fromMap(Map<String, Object?> map) => _converter.scoreFromMap(map);

  String toJson(Score score) =>
      const JsonEncoder.withIndent('  ').convert(toMap(score));

  Score fromJson(String json) =>
      fromMap(jsonDecode(json) as Map<String, Object?>);
}
