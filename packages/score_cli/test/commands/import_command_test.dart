import 'dart:io';
import 'dart:convert';

import 'package:score_cli/score_cli.dart';
import 'package:test/test.dart';

const _minimalMusicXml = '''<?xml version="1.0" encoding="UTF-8"?>
<score-partwise version="3.1">
  <movement-title>Test</movement-title>
  <part-list>
    <score-part id="P1"><part-name>Piano</part-name></score-part>
  </part-list>
  <part id="P1">
    <measure number="1">
      <attributes>
        <divisions>4</divisions>
        <key><fifths>0</fifths><mode>major</mode></key>
        <time><beats>4</beats><beat-type>4</beat-type></time>
        <clef><sign>G</sign><line>2</line></clef>
      </attributes>
    </measure>
  </part>
</score-partwise>''';

void main() {
  late Directory tempDir;

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('score_import_test_');
  });

  tearDown(() async {
    await tempDir.delete(recursive: true);
  });

  group('score import musicxml', () {
    test('imports MusicXML and creates .score.json', () async {
      final xmlPath = '${tempDir.path}/piece.xml';
      final outPath = '${tempDir.path}/piece.score.json';
      await File(xmlPath).writeAsString(_minimalMusicXml);

      final exitCode = await ScoreRunner().run([
        'import', 'musicxml',
        '--in', xmlPath,
        '--out', outPath,
      ]);
      expect(exitCode, equals(0));
      expect(File(outPath).existsSync(), isTrue);
    });

    test('output file is valid score JSON', () async {
      final xmlPath = '${tempDir.path}/piece.xml';
      final outPath = '${tempDir.path}/piece.score.json';
      await File(xmlPath).writeAsString(_minimalMusicXml);

      await ScoreRunner().run([
        'import', 'musicxml',
        '--in', xmlPath,
        '--out', outPath,
      ]);

      final content = await File(outPath).readAsString();
      final json = jsonDecode(content) as Map<String, Object?>;
      expect(json.containsKey('id'), isTrue);
    });
  });
}
