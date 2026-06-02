import 'dart:io';

import 'package:score_cli/score_cli.dart';
import 'package:test/test.dart';
import 'dart:convert';

void main() {
  late Directory tempDir;

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('score_new_test_');
  });

  tearDown(() async {
    await tempDir.delete(recursive: true);
  });

  group('score new', () {
    test('creates score file at specified path', () async {
      final outPath = '${tempDir.path}/out.score.json';
      final exitCode = await ScoreRunner().run([
        'new',
        '--title', 'Symphony No. 5',
        '--composer', 'Beethoven',
        '--out', outPath,
      ]);
      expect(exitCode, equals(0));
      expect(File(outPath).existsSync(), isTrue);
    });

    test('file contains valid JSON with title and composer', () async {
      final outPath = '${tempDir.path}/out.score.json';
      await ScoreRunner().run([
        'new',
        '--title', 'My Score',
        '--composer', 'Bach',
        '--out', outPath,
      ]);
      final content = await File(outPath).readAsString();
      final json = jsonDecode(content) as Map<String, Object?>;
      expect(json['title'], equals('My Score'));
      expect(json['composer'], equals('Bach'));
      expect(json['parts'], isA<List<dynamic>>());
      expect(json['measureHeaders'], isA<List<dynamic>>());
      expect(json.containsKey('id'), isTrue);
    });

    test('missing --out flag returns exit code 1', () async {
      final exitCode = await ScoreRunner().run([
        'new',
        '--title', 'Test',
      ]);
      expect(exitCode, equals(1));
    });
  });
}
