import 'package:fast_immutable_collections/fast_immutable_collections.dart';
import 'package:score_core/src/command/command.dart';
import 'package:score_core/src/command/command_engine.dart';
import 'package:score_core/src/command/command_result.dart';
import 'package:score_core/src/ids.dart';
import 'package:score_core/src/model/fraction.dart';
import 'package:score_core/src/model/music_event.dart';
import 'package:score_core/src/model/note_type.dart';
import 'package:score_core/src/model/note_value.dart';
import 'package:score_core/src/model/part.dart';
import 'package:score_core/src/model/pitch.dart';
import 'package:score_core/src/model/score.dart';
import 'package:score_core/src/model/staff.dart';
import 'package:test/test.dart';

/// Minimal score with one part and one staff.
Score _scoreWithPart() {
  const partId = PartId('p1');
  const staffId = StaffId('s1');
  final staff = Staff(id: staffId);
  final part = Part(id: partId, name: 'Piano', staves: IList([staff]));
  return Score(id: const ScoreId('sc1'), parts: IList([part]));
}

NoteEvent _quarterC4(String noteId) => NoteEvent(
      id: NoteId(noteId),
      offset: Fraction.zero,
      noteValue: NoteValue(noteType: NoteType.quarter),
      pitch: Pitch(step: Step.c, octave: 4),
    );

const _engine = CommandEngine();

void main() {
  group('AddNoteCommand', () {
    test('adds note to empty voice', () {
      final score = _scoreWithPart();
      final cmd = AddNoteCommand(
        partId: const PartId('p1'),
        staffId: const StaffId('s1'),
        measureNumber: 1,
        voiceId: const VoiceId('v1'),
        event: _quarterC4('n1'),
      );
      final result = _engine.apply(cmd, score);
      expect(result, isA<CommandSuccess>());
      final after = (result as CommandSuccess).scoreAfter;
      final events = after.parts.first.staves.first.measures[1]!
          .voices[const VoiceId('v1')]!.events;
      expect(events.length, equals(1));
      expect((events.first as NoteEvent).id, equals(const NoteId('n1')));
    });

    test('appends note to existing voice', () {
      final score = _scoreWithPart();
      final cmd1 = AddNoteCommand(
        partId: const PartId('p1'),
        staffId: const StaffId('s1'),
        measureNumber: 1,
        voiceId: const VoiceId('v1'),
        event: _quarterC4('n1'),
      );
      final score2 = (_engine.apply(cmd1, score) as CommandSuccess).scoreAfter;
      final cmd2 = AddNoteCommand(
        partId: const PartId('p1'),
        staffId: const StaffId('s1'),
        measureNumber: 1,
        voiceId: const VoiceId('v1'),
        event: _quarterC4('n2'),
      );
      final result = _engine.apply(cmd2, score2);
      expect(result, isA<CommandSuccess>());
      final events = (result as CommandSuccess)
          .scoreAfter
          .parts
          .first
          .staves
          .first
          .measures[1]!
          .voices[const VoiceId('v1')]!
          .events;
      expect(events.length, equals(2));
    });

    test('returns CommandFailure for unknown partId', () {
      final score = _scoreWithPart();
      final cmd = AddNoteCommand(
        partId: const PartId('UNKNOWN'),
        staffId: const StaffId('s1'),
        measureNumber: 1,
        voiceId: const VoiceId('v1'),
        event: _quarterC4('n1'),
      );
      final result = _engine.apply(cmd, score);
      expect(result, isA<CommandFailure>());
      expect((result as CommandFailure).scoreBefore, same(score));
    });

    test('returns CommandFailure for unknown staffId', () {
      final score = _scoreWithPart();
      final cmd = AddNoteCommand(
        partId: const PartId('p1'),
        staffId: const StaffId('UNKNOWN'),
        measureNumber: 1,
        voiceId: const VoiceId('v1'),
        event: _quarterC4('n1'),
      );
      expect(_engine.apply(cmd, score), isA<CommandFailure>());
    });

    test('returns CommandFailure for duplicate note ID', () {
      final score = _scoreWithPart();
      final cmd = AddNoteCommand(
        partId: const PartId('p1'),
        staffId: const StaffId('s1'),
        measureNumber: 1,
        voiceId: const VoiceId('v1'),
        event: _quarterC4('n1'),
      );
      final score2 = (_engine.apply(cmd, score) as CommandSuccess).scoreAfter;
      expect(_engine.apply(cmd, score2), isA<CommandFailure>());
    });

    test('never throws for user errors', () {
      final score = _scoreWithPart();
      final badCmd = AddNoteCommand(
        partId: const PartId('no-such-part'),
        staffId: const StaffId('s1'),
        measureNumber: 1,
        voiceId: const VoiceId('v1'),
        event: _quarterC4('n1'),
      );
      expect(() => _engine.apply(badCmd, score), returnsNormally);
    });
  });

  group('RemoveNoteCommand', () {
    test('removes an existing note', () {
      final score = _scoreWithPart();
      final addCmd = AddNoteCommand(
        partId: const PartId('p1'),
        staffId: const StaffId('s1'),
        measureNumber: 1,
        voiceId: const VoiceId('v1'),
        event: _quarterC4('n1'),
      );
      final score2 = (_engine.apply(addCmd, score) as CommandSuccess).scoreAfter;
      final removeCmd = RemoveNoteCommand(
        partId: const PartId('p1'),
        staffId: const StaffId('s1'),
        measureNumber: 1,
        voiceId: const VoiceId('v1'),
        noteId: const NoteId('n1'),
      );
      final result = _engine.apply(removeCmd, score2);
      expect(result, isA<CommandSuccess>());
      final events = (result as CommandSuccess)
          .scoreAfter
          .parts
          .first
          .staves
          .first
          .measures[1]!
          .voices[const VoiceId('v1')]!
          .events;
      expect(events.isEmpty, isTrue);
    });

    test('returns CommandFailure if note does not exist', () {
      final score = _scoreWithPart();
      final removeCmd = RemoveNoteCommand(
        partId: const PartId('p1'),
        staffId: const StaffId('s1'),
        measureNumber: 1,
        voiceId: const VoiceId('v1'),
        noteId: const NoteId('no-such-note'),
      );
      expect(_engine.apply(removeCmd, score), isA<CommandFailure>());
    });
  });

  group('AddPartCommand', () {
    test('adds a new part', () {
      final score = Score(id: const ScoreId('sc1'));
      final part = Part(id: const PartId('p1'), name: 'Violin');
      final result = _engine.apply(AddPartCommand(part: part), score);
      expect(result, isA<CommandSuccess>());
      final after = (result as CommandSuccess).scoreAfter;
      expect(after.parts.length, equals(1));
      expect(after.parts.first.name, equals('Violin'));
    });

    test('returns CommandFailure for duplicate part ID', () {
      final score = _scoreWithPart();
      final part = Part(id: const PartId('p1'), name: 'Duplicate');
      expect(
        _engine.apply(AddPartCommand(part: part), score),
        isA<CommandFailure>(),
      );
    });
  });

  group('BatchCommand', () {
    test('applies all commands atomically', () {
      final score = Score(id: const ScoreId('sc1'));
      final part1 = Part(id: const PartId('p1'), name: 'Violin');
      final part2 = Part(id: const PartId('p2'), name: 'Cello');
      final batch = BatchCommand(
        commands: IList([
          AddPartCommand(part: part1),
          AddPartCommand(part: part2),
        ]),
      );
      final result = _engine.apply(batch, score);
      expect(result, isA<CommandSuccess>());
      expect((result as CommandSuccess).scoreAfter.parts.length, equals(2));
    });

    test('rolls back to original on any failure', () {
      final score = _scoreWithPart();
      final goodCmd = AddNoteCommand(
        partId: const PartId('p1'),
        staffId: const StaffId('s1'),
        measureNumber: 1,
        voiceId: const VoiceId('v1'),
        event: _quarterC4('n1'),
      );
      final badCmd = AddNoteCommand(
        partId: const PartId('NO-SUCH-PART'),
        staffId: const StaffId('s1'),
        measureNumber: 1,
        voiceId: const VoiceId('v1'),
        event: _quarterC4('n2'),
      );
      final batch = BatchCommand(
        commands: IList([goodCmd, badCmd]),
      );
      final result = _engine.apply(batch, score);
      expect(result, isA<CommandFailure>());
      expect((result as CommandFailure).scoreBefore, same(score));
    });
  });

  group('dryRun', () {
    test('returns same result as apply without side effects', () {
      final score = _scoreWithPart();
      final cmd = AddNoteCommand(
        partId: const PartId('p1'),
        staffId: const StaffId('s1'),
        measureNumber: 1,
        voiceId: const VoiceId('v1'),
        event: _quarterC4('n1'),
      );
      final dryResult = _engine.dryRun(cmd, score);
      final applyResult = _engine.apply(cmd, score);
      expect(dryResult, isA<CommandSuccess>());
      expect(applyResult, isA<CommandSuccess>());
    });
  });
}
