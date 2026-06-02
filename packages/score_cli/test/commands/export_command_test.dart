import 'dart:io';

import 'package:score_cli/score_cli.dart';
import 'package:score_core/score_core.dart';
import 'package:score_io/score_io.dart';
import 'package:test/test.dart';

void main() {
  late Directory tempDir;

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('score_export_test_');
  });

  tearDown(() async {
    await tempDir.delete(recursive: true);
  });

  Future<String> saveEmptyScore() async {
    final score = Score(id: IdFactory.score(), title: 'Export Test');
    final path = '${tempDir.path}/source.score.json';
    await ScoreIo.saveJson(score, path);
    return path;
  }

  group('score export musicxml', () {
    test('exports score to MusicXML file', () async {
      final inPath = await saveEmptyScore();
      final outPath = '${tempDir.path}/output.xml';

      final exitCode = await ScoreRunner().run([
        'export', 'musicxml',
        '--in', inPath,
        '--out', outPath,
      ]);
      expect(exitCode, equals(0));
      expect(File(outPath).existsSync(), isTrue);
    });

    test('output file starts with <?xml', () async {
      final inPath = await saveEmptyScore();
      final outPath = '${tempDir.path}/output.xml';

      await ScoreRunner().run([
        'export', 'musicxml',
        '--in', inPath,
        '--out', outPath,
      ]);

      final content = await File(outPath).readAsString();
      expect(content.trimLeft().startsWith('<?xml'), isTrue);
    });
  });

  group('score export midi', () {
    test('exports score to MIDI file', () async {
      final inPath = await saveEmptyScore();
      final outPath = '${tempDir.path}/output.mid';

      final exitCode = await ScoreRunner().run([
        'export', 'midi',
        '--in', inPath,
        '--out', outPath,
      ]);
      expect(exitCode, equals(0));
      expect(File(outPath).existsSync(), isTrue);
    });

    test('output file starts with MThd bytes', () async {
      final inPath = await saveEmptyScore();
      final outPath = '${tempDir.path}/output.mid';

      await ScoreRunner().run([
        'export', 'midi',
        '--in', inPath,
        '--out', outPath,
      ]);

      final bytes = await File(outPath).readAsBytes();
      final header = String.fromCharCodes(bytes.sublist(0, 4));
      expect(header, equals('MThd'));
    });
  });
}
