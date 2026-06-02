import 'package:score_core/score_core.dart';
import 'package:score_io/score_io.dart';
import 'package:test/test.dart';

void main() {
  const migrator = SchemaMigrator();

  group('SchemaMigrator', () {
    test('version 1 data passes through unchanged', () {
      final data = <String, Object?>{
        r'$schema_version': 1,
        'id': 'score-1',
        'title': 'Test',
      };
      final result = migrator.migrate(data);
      expect(result[r'$schema_version'], equals(1));
      expect(result['id'], equals('score-1'));
      expect(result['title'], equals('Test'));
    });

    test('data at current version returns same map', () {
      final data = <String, Object?>{
        r'$schema_version': SchemaMigrator.currentVersion,
        'id': 'score-1',
      };
      final result = migrator.migrate(data);
      expect(result, equals(data));
    });

    test('unknown future version throws ScoreException', () {
      final data = <String, Object?>{
        r'$schema_version': 9999,
        'id': 'score-1',
      };
      expect(() => migrator.migrate(data), throwsA(isA<ScoreException>()));
    });
  });
}
