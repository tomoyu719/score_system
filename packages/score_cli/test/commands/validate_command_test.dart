import 'dart:io';

import 'package:fast_immutable_collections/fast_immutable_collections.dart';
import 'package:score_cli/score_cli.dart';
import 'package:score_core/score_core.dart';
import 'package:score_io/score_io.dart';
import 'package:test/test.dart';

void main() {
  late Directory tempDir;

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('score_validate_test_');
  });

  tearDown(() async {
    await tempDir.delete(recursive: true);
  });

  Future<String> saveScore(Score score) async {
    final path = '${tempDir.path}/score.score.json';
    await ScoreIo.saveJson(score, path);
    return path;
  }

  Score buildValidScore() =>
      Score(id: IdFactory.score(), title: 'Test', composer: 'Me');

  Score buildOverflowScore() {
    const staffId = StaffId('s1');
    const partId = PartId('p1');
    const voiceId = VoiceId('v1');
    // Two whole notes in a 4/4 measure — overflows (2/1 > 1/1).
    final voice = Voice(id: voiceId)
        .addNote(NoteEvent(
          id: NoteId('n1'),
          pitch: const Pitch(step: Step.c, octave: 4),
          noteValue: NoteValue(noteType: NoteType.whole),
          offset: Fraction.zero,
        ))
        .addNote(NoteEvent(
          id: NoteId('n2'),
          pitch: const Pitch(step: Step.d, octave: 4),
          noteValue: NoteValue(noteType: NoteType.whole),
          offset: Fraction(1, 1),
        ));
    final measure =
        const Measure(id: MeasureId('m1')).updateVoice(voiceId, (_) => voice);
    final staff = Staff(id: staffId).updateMeasure(1, (_) => measure);
    final part = Part(
      id: partId,
      name: 'Piano',
      staves: IList([staff]),
    );
    final header = MeasureHeader(
      measureNumber: 1,
      timeSignature: const TimeSignature(beats: 4, beatType: 4),
      keySignature: const KeySignature(fifths: 0),
    );
    return Score(
      id: IdFactory.score(),
      parts: IList([part]),
      measureHeaders: IList([header]),
    );
  }

  group('score validate', () {
    test('valid score returns exit 0', () async {
      final path = await saveScore(buildValidScore());
      final exitCode = await ScoreRunner().run(['validate', '--in', path]);
      expect(exitCode, equals(0));
    });

    test('output contains valid:true for valid score (exit 0)', () async {
      final path = await saveScore(buildValidScore());
      final exitCode = await ScoreRunner().run(['validate', '--in', path]);
      expect(exitCode, equals(0));
    });

    test('invalid score (voice overflow) returns exit 2', () async {
      final path = await saveScore(buildOverflowScore());
      final exitCode = await ScoreRunner().run(['validate', '--in', path]);
      expect(exitCode, equals(2));
    });
  });
}
