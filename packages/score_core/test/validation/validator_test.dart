import 'package:score_core/src/ids.dart';
import 'package:score_core/src/model/fraction.dart';
import 'package:score_core/src/model/key_signature.dart';
import 'package:score_core/src/model/measure.dart';
import 'package:score_core/src/model/measure_header.dart';
import 'package:score_core/src/model/music_event.dart';
import 'package:score_core/src/model/note_type.dart';
import 'package:score_core/src/model/note_value.dart';
import 'package:score_core/src/model/part.dart';
import 'package:score_core/src/model/pitch.dart';
import 'package:score_core/src/model/score.dart';
import 'package:score_core/src/model/staff.dart';
import 'package:score_core/src/model/time_signature.dart';
import 'package:score_core/src/model/voice.dart';
import 'package:score_core/src/validation/validation_error.dart';
import 'package:score_core/src/validation/validation_result.dart';
import 'package:score_core/src/validation/validator.dart';
import 'package:test/test.dart';

// ── Fixtures ──────────────────────────────────────────────────────────────────

const _validator = Validator();

NoteEvent _note(String id, Step step, int octave,
        {NoteType type = NoteType.quarter, double alter = 0}) =>
    NoteEvent(
      id: NoteId(id),
      pitch: Pitch(step: step, octave: octave, alter: alter),
      offset: Fraction.zero,
      noteValue: NoteValue(noteType: type),
    );

Score _scoreWith({
  required Voice voice,
  TimeSignature timeSignature = const TimeSignature(beats: 4, beatType: 4),
}) {
  const staffId = StaffId('s1');
  const partId = PartId('p1');
  const voiceId = VoiceId('v1');

  final measure = const Measure(id: MeasureId('m1'))
      .updateVoice(voiceId, (_) => voice);
  final staff = Staff(id: staffId).updateMeasure(1, (_) => measure);
  final part = Part(
    id: partId,
    name: 'Piano',
    staves: Part(id: partId, name: '').staves.add(staff),
  );
  final header = MeasureHeader(
    measureNumber: 1,
    timeSignature: timeSignature,
    keySignature: const KeySignature(fifths: 0),
  );
  return Score(
    id: const ScoreId('score1'),
    parts: Score(id: const ScoreId('score1')).parts.add(part),
    measureHeaders: Score(id: const ScoreId('score1'))
        .measureHeaders
        .add(header),
  );
}

void main() {
  group('Validator — empty score', () {
    test('empty score is valid', () {
      final result = _validator.validate(Score(id: const ScoreId('s')));
      expect(result, isA<ValidationSuccess>());
    });
  });

  // ── T24: Voice duration / time-signature overflow ─────────────────────────

  group('Validator — voice overflow (T24)', () {
    test('4 quarter notes in 4/4 is valid', () {
      final voice = Voice(id: const VoiceId('v1'))
          .addNote(_note('n1', Step.c, 4))
          .addNote(_note('n2', Step.d, 4))
          .addNote(_note('n3', Step.e, 4))
          .addNote(_note('n4', Step.f, 4));
      final result = _validator.validate(_scoreWith(voice: voice));
      expect(result, isA<ValidationSuccess>());
    });

    test('5 quarter notes in 4/4 is invalid (VOICE_OVERFLOW)', () {
      final voice = Voice(id: const VoiceId('v1'))
          .addNote(_note('n1', Step.c, 4))
          .addNote(_note('n2', Step.d, 4))
          .addNote(_note('n3', Step.e, 4))
          .addNote(_note('n4', Step.f, 4))
          .addNote(_note('n5', Step.g, 4));
      final result = _validator.validate(_scoreWith(voice: voice));
      expect(result, isA<ValidationFailure>());
      final failure = result as ValidationFailure;
      expect(failure.errors.length, equals(1));
      expect(failure.errors[0].code, equals('VOICE_OVERFLOW'));
    });

    test('3 quarter notes in 3/4 is valid', () {
      final voice = Voice(id: const VoiceId('v1'))
          .addNote(_note('n1', Step.c, 4))
          .addNote(_note('n2', Step.d, 4))
          .addNote(_note('n3', Step.e, 4));
      final result = _validator.validate(_scoreWith(
        voice: voice,
        timeSignature: const TimeSignature(beats: 3, beatType: 4),
      ));
      expect(result, isA<ValidationSuccess>());
    });

    test('voice with no header is skipped (no crash)', () {
      // Score with a measure but no MeasureHeader — should not crash.
      const staffId = StaffId('s1');
      const partId = PartId('p1');
      const voiceId = VoiceId('v1');
      final voice = Voice(id: voiceId)
          .addNote(_note('n1', Step.c, 4))
          .addNote(_note('n2', Step.c, 4))
          .addNote(_note('n3', Step.c, 4))
          .addNote(_note('n4', Step.c, 4))
          .addNote(_note('n5', Step.c, 4));
      final measure =
          const Measure(id: MeasureId('m1')).updateVoice(voiceId, (_) => voice);
      final staff = Staff(id: staffId).updateMeasure(1, (_) => measure);
      final part = Part(
        id: partId,
        name: 'Piano',
        staves: Part(id: partId, name: '').staves.add(staff),
      );
      final score = Score(
        id: const ScoreId('s'),
        parts: Score(id: const ScoreId('s')).parts.add(part),
      );
      // No MeasureHeader — overflow check is skipped, no crash.
      expect(() => _validator.validate(score), returnsNormally);
    });
  });

  // ── T25: Pitch range ──────────────────────────────────────────────────────

  group('Validator — pitch range (T25)', () {
    test('C4 (midi 60) is valid', () {
      final voice =
          Voice(id: const VoiceId('v1')).addNote(_note('n1', Step.c, 4));
      final result = _validator.validate(_scoreWith(voice: voice));
      expect(result, isA<ValidationSuccess>());
    });

    test('C0 (midi 12) is valid', () {
      final voice =
          Voice(id: const VoiceId('v1')).addNote(_note('n1', Step.c, 0));
      final result = _validator.validate(_scoreWith(voice: voice));
      expect(result, isA<ValidationSuccess>());
    });

    test('note with alter pushing midi > 127 is invalid', () {
      // B9 = midi 131; alter +2 = 133 — out of range.
      final voice = Voice(id: const VoiceId('v1'))
          .addNote(_note('n1', Step.b, 9, alter: 2.0));
      final result = _validator.validate(_scoreWith(
        voice: voice,
        timeSignature: const TimeSignature(beats: 4, beatType: 4),
      ));
      expect(result, isA<ValidationFailure>());
      final failure = result as ValidationFailure;
      expect(failure.errors.any((e) => e.code == 'PITCH_OUT_OF_RANGE'), isTrue);
    });
  });

  // ── T26: ValidationResult.toJson ─────────────────────────────────────────

  group('ValidationResult.toJson (T26)', () {
    test('ValidationSuccess toJson contains valid:true and empty errors', () {
      final json = const ValidationSuccess().toJson();
      expect(json['valid'], isTrue);
      expect((json['errors'] as List).isEmpty, isTrue);
    });

    test('ValidationFailure toJson contains valid:false and error list', () {
      const error = ValidationError(
        code: 'VOICE_OVERFLOW',
        message: 'too long',
        partId: 'p1',
        measureNumber: 1,
      );
      final json = ValidationFailure(errors: [error]).toJson();
      expect(json['valid'], isFalse);
      final errors = json['errors'] as List;
      expect(errors.length, equals(1));
      expect((errors[0] as Map)['code'], equals('VOICE_OVERFLOW'));
      expect((errors[0] as Map)['partId'], equals('p1'));
      expect((errors[0] as Map).containsKey('staffId'), isFalse);
    });

    test('ValidationError omits null fields from toJson', () {
      const error = ValidationError(code: 'X', message: 'y');
      final json = error.toJson();
      expect(json.containsKey('partId'), isFalse);
      expect(json.containsKey('staffId'), isFalse);
      expect(json.containsKey('measureNumber'), isFalse);
      expect(json.containsKey('voiceId'), isFalse);
    });

    test('round-trip: validate failure produces serialisable JSON', () {
      final voice = Voice(id: const VoiceId('v1'))
          .addNote(_note('n1', Step.c, 4))
          .addNote(_note('n2', Step.c, 4))
          .addNote(_note('n3', Step.c, 4))
          .addNote(_note('n4', Step.c, 4))
          .addNote(_note('n5', Step.c, 4));
      final result = _validator.validate(_scoreWith(voice: voice));
      expect(result, isA<ValidationFailure>());
      final json = result.toJson();
      expect(json['valid'], isFalse);
      expect((json['errors'] as List).isNotEmpty, isTrue);
    });
  });
}
