import 'package:score_core/src/ids.dart';
import 'package:score_core/src/model/fraction.dart';
import 'package:score_core/src/model/measure.dart';
import 'package:score_core/src/model/music_event.dart';
import 'package:score_core/src/model/note_type.dart';
import 'package:score_core/src/model/note_value.dart';
import 'package:score_core/src/model/part.dart';
import 'package:score_core/src/model/pitch.dart';
import 'package:score_core/src/model/score.dart';
import 'package:score_core/src/model/staff.dart';
import 'package:score_core/src/model/voice.dart';
import 'package:test/test.dart';

NoteEvent _note(String id) => NoteEvent(
      id: NoteId(id),
      pitch: const Pitch(step: Step.c, octave: 4),
      offset: Fraction.zero,
      noteValue: const NoteValue(noteType: NoteType.quarter),
    );

// ── Fixtures ──────────────────────────────────────────────────────────────────

final _partId = const PartId('p1');
final _staffId = const StaffId('s1');
final _voiceId = const VoiceId('v1');

Staff _staffWith(int measureNumber, Measure measure) => Staff(
      id: _staffId,
      measures: Staff(id: _staffId).measures.add(measureNumber, measure),
    );

Part _partWith(Staff staff) =>
    Part(id: _partId, name: 'Piano', staves: Part(id: _partId, name: '').staves.add(staff));

Score _scoreWith(Part part) => Score(
      id: const ScoreId('score1'),
      parts: Score(id: const ScoreId('score1')).parts.add(part),
    );

void main() {
  // ── Measure.updateVoice ───────────────────────────────────────────────────

  group('Measure.updateVoice', () {
    test('creates new Voice when VoiceId absent', () {
      const measure = Measure(id: MeasureId('m1'));
      final updated = measure.updateVoice(_voiceId, (v) => v);
      expect(updated.voices[_voiceId], isNotNull);
      expect(updated.voices[_voiceId]!.id, equals(_voiceId));
    });

    test('updates existing Voice', () {
      const measure = Measure(id: MeasureId('m1'));
      final withVoice = measure.updateVoice(_voiceId, (v) => v);
      // Updater replaces the voice stored under _voiceId with a new one.
      final updated = withVoice.updateVoice(
          _voiceId, (v) => Voice(id: const VoiceId('v2')));
      expect(updated.voices.containsKey(_voiceId), isTrue);
      expect(updated.voices[_voiceId]!.id, equals(const VoiceId('v2')));
    });

    test('does not mutate original Measure', () {
      const measure = Measure(id: MeasureId('m1'));
      measure.updateVoice(_voiceId, (v) => v);
      expect(measure.voices.isEmpty, isTrue);
    });
  });

  // ── Staff.updateMeasure ───────────────────────────────────────────────────

  group('Staff.updateMeasure', () {
    test('creates new Measure when measureNumber absent', () {
      const staff = Staff(id: StaffId('s1'));
      final updated = staff.updateMeasure(1, (m) => m);
      expect(updated.measures[1], isNotNull);
      expect(updated.measures[1]!.id.value, isNotEmpty);
    });

    test('updates existing Measure', () {
      const originalMeasure = Measure(id: MeasureId('m-original'));
      final staff = _staffWith(1, originalMeasure);
      final updated = staff.updateMeasure(
          1, (m) => m.updateVoice(_voiceId, (v) => v));
      expect(updated.measures[1]!.voices[_voiceId], isNotNull);
    });

    test('does not mutate original Staff', () {
      const staff = Staff(id: StaffId('s1'));
      staff.updateMeasure(1, (m) => m);
      expect(staff.measures.isEmpty, isTrue);
    });

    test('newly created Measure has a non-empty MeasureId', () {
      const staff = Staff(id: StaffId('s1'));
      final updated = staff.updateMeasure(1, (m) => m);
      expect(updated.measures[1]!.id.value, isNotEmpty);
    });
  });

  // ── Part.updateStaff ─────────────────────────────────────────────────────

  group('Part.updateStaff', () {
    test('returns null when StaffId not found', () {
      final part = Part(id: _partId, name: 'Piano');
      expect(
          part.updateStaff(const StaffId('missing'), (s) => s), isNull);
    });

    test('returns updated Part when StaffId found', () {
      const staff = Staff(id: StaffId('s1'));
      final part = _partWith(staff);
      final updated = part.updateStaff(
          _staffId, (s) => s.updateMeasure(1, (m) => m));
      expect(updated, isNotNull);
      expect(updated!.staves[0].measures[1], isNotNull);
    });

    test('does not mutate original Part', () {
      const staff = Staff(id: StaffId('s1'));
      final part = _partWith(staff);
      part.updateStaff(_staffId, (s) => s.updateMeasure(1, (m) => m));
      expect(part.staves[0].measures.isEmpty, isTrue);
    });

    test('propagates null when updater returns null', () {
      const staff = Staff(id: StaffId('s1'));
      final part = _partWith(staff);
      final result = part.updateStaff(_staffId, (s) => null);
      expect(result, isNull);
    });
  });

  // ── Score.updatePart ─────────────────────────────────────────────────────

  group('Score.updatePart', () {
    test('returns null when PartId not found', () {
      final score = Score(id: const ScoreId('score1'));
      expect(
          score.updatePart(const PartId('missing'), (p) => p), isNull);
    });

    test('returns updated Score when PartId found', () {
      final part = Part(id: _partId, name: 'Piano');
      final score = _scoreWith(part);
      final updated =
          score.updatePart(_partId, (p) => p.copyWith(name: 'Violin'));
      expect(updated, isNotNull);
      expect(updated!.parts[0].name, equals('Violin'));
    });

    test('does not mutate original Score', () {
      final part = Part(id: _partId, name: 'Piano');
      final score = _scoreWith(part);
      score.updatePart(_partId, (p) => p.copyWith(name: 'Violin'));
      expect(score.parts[0].name, equals('Piano'));
    });

    test('propagates null from updater returning null', () {
      final part = Part(id: _partId, name: 'Piano');
      final score = _scoreWith(part);
      final result = score.updatePart(_partId, (p) => null);
      expect(result, isNull);
    });
  });

  // ── Full chain integration ────────────────────────────────────────────────

  group('full update chain', () {
    late Score score;

    setUp(() {
      const staff = Staff(id: StaffId('s1'));
      final part = _partWith(staff);
      score = _scoreWith(part);
    });

    test('nested chain produces correct result', () {
      final updated = score.updatePart(
        _partId,
        (p) => p.updateStaff(
          _staffId,
          (s) => s.updateMeasure(
            1,
            (m) => m.updateVoice(_voiceId, (v) => v),
          ),
        ),
      );
      expect(updated, isNotNull);
      expect(
        updated!.parts[0].staves[0].measures[1]!.voices[_voiceId],
        isNotNull,
      );
    });

    test('chain returns null when PartId invalid', () {
      final result = score.updatePart(
        const PartId('no-such-part'),
        (p) => p.updateStaff(_staffId, (s) => s),
      );
      expect(result, isNull);
    });

    test('chain returns null when StaffId invalid', () {
      final result = score.updatePart(
        _partId,
        (p) => p.updateStaff(const StaffId('no-such-staff'), (s) => s),
      );
      expect(result, isNull);
    });
  });

  // ── Score.findPart ───────────────────────────────────────────────────────

  group('Score.findPart', () {
    test('returns Part when found', () {
      final part = Part(id: _partId, name: 'Piano');
      final score = _scoreWith(part);
      expect(score.findPart(_partId), same(part));
    });

    test('returns null when not found', () {
      final score = Score(id: const ScoreId('s'));
      expect(score.findPart(_partId), isNull);
    });
  });

  // ── Part.findStaff ───────────────────────────────────────────────────────

  group('Part.findStaff', () {
    test('returns Staff when found', () {
      const staff = Staff(id: StaffId('s1'));
      final part = _partWith(staff);
      expect(part.findStaff(_staffId), same(staff));
    });

    test('returns null when not found', () {
      final part = Part(id: _partId, name: 'Piano');
      expect(part.findStaff(_staffId), isNull);
    });
  });

  // ── Staff.findVoice ──────────────────────────────────────────────────────

  group('Staff.findVoice', () {
    test('returns Voice when measure and voice exist', () {
      const voice = Voice(id: VoiceId('v1'));
      final measure =
          Measure(id: const MeasureId('m1')).updateVoice(_voiceId, (v) => voice);
      final staff = _staffWith(1, measure);
      expect(staff.findVoice(1, _voiceId), isNotNull);
    });

    test('returns null when measure does not exist', () {
      const staff = Staff(id: StaffId('s1'));
      expect(staff.findVoice(99, _voiceId), isNull);
    });

    test('returns null when voice does not exist in measure', () {
      const measure = Measure(id: MeasureId('m1'));
      final staff = _staffWith(1, measure);
      expect(staff.findVoice(1, _voiceId), isNull);
    });
  });

  // ── Voice.containsNote / indexOfNote ─────────────────────────────────────

  group('Voice.containsNote', () {
    test('returns true when note present', () {
      final note = _note('n1');
      final voice = Voice(id: _voiceId).addNote(note);
      expect(voice.containsNote(note.id), isTrue);
    });

    test('returns false when note absent', () {
      const voice = Voice(id: VoiceId('v1'));
      expect(voice.containsNote(const NoteId('missing')), isFalse);
    });
  });

  group('Voice.indexOfNote', () {
    test('returns correct index', () {
      final n1 = _note('n1');
      final n2 = _note('n2');
      final voice = Voice(id: _voiceId).addNote(n1).addNote(n2);
      expect(voice.indexOfNote(n2.id), equals(1));
    });

    test('returns -1 when not found', () {
      const voice = Voice(id: VoiceId('v1'));
      expect(voice.indexOfNote(const NoteId('missing')), equals(-1));
    });
  });

  // ── Voice.addNote / removeNoteAt ─────────────────────────────────────────

  group('Voice.addNote', () {
    test('appends note to events', () {
      final note = _note('n1');
      final voice = Voice(id: _voiceId).addNote(note);
      expect(voice.events.length, equals(1));
      expect(voice.events[0], same(note));
    });

    test('does not mutate original', () {
      const original = Voice(id: VoiceId('v1'));
      original.addNote(_note('n1'));
      expect(original.events.isEmpty, isTrue);
    });
  });

  group('Voice.removeNoteAt', () {
    test('removes event at given index', () {
      final n1 = _note('n1');
      final n2 = _note('n2');
      final voice = Voice(id: _voiceId).addNote(n1).addNote(n2);
      final updated = voice.removeNoteAt(0);
      expect(updated.events.length, equals(1));
      expect((updated.events[0] as NoteEvent).id, equals(n2.id));
    });

    test('does not mutate original', () {
      final note = _note('n1');
      final voice = Voice(id: _voiceId).addNote(note);
      voice.removeNoteAt(0);
      expect(voice.events.length, equals(1));
    });
  });
}
