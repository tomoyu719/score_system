import 'package:fast_immutable_collections/fast_immutable_collections.dart';
import 'package:score_core/score_core.dart';
import 'package:score_layout/score_layout.dart';
import 'package:test/test.dart';

void main() {
  const detector = SharedNoteheadDetector();

  const partId = PartId('part-1');
  const staffId = StaffId('staff-1');
  const v1 = VoiceId('v1');
  const v2 = VoiceId('v2');
  const c4 = Pitch(step: Step.c, octave: 4);
  const d4 = Pitch(step: Step.d, octave: 4);
  const quarterNote = NoteValue(noteType: NoteType.quarter);

  VoiceContext makeVoiceContext(
    VoiceId voiceId,
    List<NoteEvent> notes,
  ) {
    return VoiceContext(
      partId: partId,
      staffId: staffId,
      measureNumber: 1,
      voiceId: voiceId,
      voice: Voice(id: voiceId, events: IList(notes)),
    );
  }

  NoteEvent makeNote(String id, Pitch pitch, Fraction offset) => NoteEvent(
        id: NoteId(id),
        offset: offset,
        noteValue: quarterNote,
        pitch: pitch,
      );

  group('SharedNoteheadDetector', () {
    test('two voices with same pitch at same offset → detected', () {
      final note1 = makeNote('n1', c4, Fraction.zero);
      final note2 = makeNote('n2', c4, Fraction.zero);
      final contexts = [
        makeVoiceContext(v1, [note1]),
        makeVoiceContext(v2, [note2]),
      ];
      final pairs = detector.findShared(contexts);
      expect(pairs.length, 1);
      expect(
        pairs.first,
        anyOf(
          equals(('n1', 'n2')),
          equals(('n2', 'n1')),
        ),
      );
    });

    test('same pitch but different offset → not detected', () {
      final note1 = makeNote('n1', c4, Fraction.zero);
      final note2 = makeNote('n2', c4, Fraction(1, 4));
      final contexts = [
        makeVoiceContext(v1, [note1]),
        makeVoiceContext(v2, [note2]),
      ];
      expect(detector.findShared(contexts), isEmpty);
    });

    test('different pitch same offset → not detected', () {
      final note1 = makeNote('n1', c4, Fraction.zero);
      final note2 = makeNote('n2', d4, Fraction.zero);
      final contexts = [
        makeVoiceContext(v1, [note1]),
        makeVoiceContext(v2, [note2]),
      ];
      expect(detector.findShared(contexts), isEmpty);
    });

    test('same voice → not detected (same-voice notes are not shared)', () {
      final note1 = makeNote('n1', c4, Fraction.zero);
      final note2 = makeNote('n2', c4, Fraction.zero);
      final contexts = [
        makeVoiceContext(v1, [note1, note2]),
      ];
      expect(detector.findShared(contexts), isEmpty);
    });
  });
}
