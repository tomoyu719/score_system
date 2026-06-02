import 'dart:io';

import 'package:fast_immutable_collections/fast_immutable_collections.dart';
import 'package:score_cli/score_cli.dart';
import 'package:score_core/score_core.dart';
import 'package:score_io/score_io.dart';
import 'package:test/test.dart';

void main() {
  late Directory tempDir;

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('score_diff_test_');
  });

  tearDown(() async {
    await tempDir.delete(recursive: true);
  });

  Future<String> savePath(Score score, String name) async {
    final path = '${tempDir.path}/$name';
    await ScoreIo.saveJson(score, path);
    return path;
  }

  group('score diff', () {
    test('same score returns exit 0', () async {
      final score = Score(id: IdFactory.score(), title: 'Same');
      final pathA = await savePath(score, 'a.score.json');
      final pathB = await savePath(score, 'b.score.json');
      final exitCode = await ScoreRunner().run([
        'diff',
        '--a', pathA,
        '--b', pathB,
      ]);
      expect(exitCode, equals(0));
    });

    test('different titles returns exit 0 (outputs differences)', () async {
      final scoreA =
          Score(id: IdFactory.score(), title: 'Old Title', composer: 'X');
      final scoreB =
          Score(id: IdFactory.score(), title: 'New Title', composer: 'X');
      final pathA = await savePath(scoreA, 'a.score.json');
      final pathB = await savePath(scoreB, 'b.score.json');
      final exitCode = await ScoreRunner().run([
        'diff',
        '--a', pathA,
        '--b', pathB,
      ]);
      expect(exitCode, equals(0));
    });

    test('different part counts returns exit 0 (outputs differences)', () async {
      final baseId = IdFactory.score();
      final scoreA = Score(id: baseId, title: 'T');
      final partId = IdFactory.part();
      final scoreB = scoreA.copyWith(
        parts: IList([Part(id: partId, name: 'Piano')]),
      );
      final pathA = await savePath(scoreA, 'a.score.json');
      final pathB = await savePath(scoreB, 'b.score.json');
      final exitCode = await ScoreRunner().run([
        'diff',
        '--a', pathA,
        '--b', pathB,
      ]);
      expect(exitCode, equals(0));
    });
  });
}
