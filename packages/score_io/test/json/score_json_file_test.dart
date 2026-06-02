import 'dart:io';

import 'package:score_core/score_core.dart';
import 'package:score_io/score_io.dart';
import 'package:test/test.dart';

void main() {
  group('ScoreJsonFile', () {
    late Directory tempDir;

    setUp(() {
      tempDir = Directory.systemTemp.createTempSync('score_io_test_');
    });

    tearDown(() {
      tempDir.deleteSync(recursive: true);
    });

    test('save and load roundtrip', () async {
      final score = Score(
        id: const ScoreId('score-file-1'),
        title: 'File Roundtrip',
        composer: 'Test Composer',
      );
      final path = '${tempDir.path}/test.score.json';
      await ScoreJsonFile.save(score, path);
      final loaded = await ScoreJsonFile.load(path);
      expect(loaded.id, equals(score.id));
      expect(loaded.title, equals(score.title));
      expect(loaded.composer, equals(score.composer));
    });

    test('file has 2-space indent', () async {
      final score = Score(
        id: const ScoreId('score-file-2'),
        title: 'Indent Test',
      );
      final path = '${tempDir.path}/indent.score.json';
      await ScoreJsonFile.save(score, path);
      final content = File(path).readAsStringSync();
      expect(content, contains('  "id"'));
    });

    test('load non-existent file throws ScoreException', () async {
      final path = '${tempDir.path}/does_not_exist.score.json';
      expect(
        () => ScoreJsonFile.load(path),
        throwsA(isA<ScoreException>()),
      );
    });
  });
}
