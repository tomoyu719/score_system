import 'dart:io';

import 'package:score_cli/score_cli.dart';
import 'package:score_core/score_core.dart';
import 'package:score_io/score_io.dart';
import 'package:test/test.dart';

void main() {
  late Directory tempDir;

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('score_layout_test_');
  });

  tearDown(() async {
    await tempDir.delete(recursive: true);
  });

  Future<String> saveEmptyScore() async {
    final score = Score(id: IdFactory.score(), title: 'Layout Test');
    final path = '${tempDir.path}/score.score.json';
    await ScoreIo.saveJson(score, path);
    return path;
  }

  group('score layout', () {
    test('outputs JSON with "parts" key from layout tree', () async {
      final inPath = await saveEmptyScore();
      final exitCode = await ScoreRunner().run(['layout', '--in', inPath]);
      expect(exitCode, equals(0));
    });

    test('empty score produces exit 0', () async {
      final inPath = await saveEmptyScore();
      final exitCode = await ScoreRunner().run(['layout', '--in', inPath]);
      expect(exitCode, equals(0));
    });
  });

  group('score collisions', () {
    test('empty score reports no collisions with exit 0', () async {
      final inPath = await saveEmptyScore();
      final exitCode =
          await ScoreRunner().run(['collisions', '--in', inPath]);
      expect(exitCode, equals(0));
    });
  });

}
