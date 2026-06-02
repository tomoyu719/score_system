import 'dart:io';

import 'package:score_cli/score_cli.dart';
import 'package:score_core/score_core.dart';
import 'package:score_io/score_io.dart';
import 'package:test/test.dart';

void main() {
  late Directory tempDir;

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('score_inspect_test_');
  });

  tearDown(() async {
    await tempDir.delete(recursive: true);
  });

  Future<String> saveEmptyScore() async {
    final score =
        Score(id: IdFactory.score(), title: 'Inspect Test', composer: 'Bach');
    final path = '${tempDir.path}/score.score.json';
    await ScoreIo.saveJson(score, path);
    return path;
  }

  group('score inspect', () {
    test('outputs id/title/parts/measureHeaderCount with exit 0', () async {
      final inPath = await saveEmptyScore();
      final exitCode = await ScoreRunner().run(['inspect', '--in', inPath]);
      expect(exitCode, equals(0));
    });

    test('--midi flag outputs dump with exit 0', () async {
      final inPath = await saveEmptyScore();
      final exitCode =
          await ScoreRunner().run(['inspect', '--in', inPath, '--midi']);
      expect(exitCode, equals(0));
    });
  });
}
