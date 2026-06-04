import 'package:fast_immutable_collections/fast_immutable_collections.dart';
import 'package:score_core/score_core.dart';
import 'package:score_layout/score_layout.dart';
import 'package:test/test.dart';

Score _quarterNoteScore({
  Clef clef = Clef.treble,
  required List<({NoteId id, Pitch pitch, Fraction offset})> notes,
}) {
  final events = notes
      .map((n) => NoteEvent(
            id: n.id,
            offset: n.offset,
            noteValue: NoteValue(noteType: NoteType.quarter),
            pitch: n.pitch,
          ))
      .toList();
  return Score(
    id: const ScoreId('s'),
    parts: IList([
      Part(
        id: const PartId('p1'),
        name: 'Piano',
        staves: IList([
          Staff(
            id: const StaffId('s1'),
            clef: clef,
            measures: IMap({
              1: Measure(
                id: const MeasureId('m1'),
                voices: IMap({
                  const VoiceId('v1'): Voice(
                    id: const VoiceId('v1'),
                    events: IList(events),
                  ),
                }),
              ),
            }),
          ),
        ]),
      ),
    ]),
    measureHeaders: IList([
      MeasureHeader(
        measureNumber: 1,
        timeSignature: const TimeSignature(beats: 4, beatType: 4),
        keySignature: const KeySignature(fifths: 0),
      ),
    ]),
  );
}

void main() {
  final calc = LayoutCalculator();

  group('LayoutCalculator', () {
    test('empty score produces empty LayoutTree', () {
      final tree = calc.calculate(Score(id: const ScoreId('s')));
      expect(tree.systems, isEmpty);
    });

    test('single quarter C4 in treble clef → staffLine -2', () {
      final score = _quarterNoteScore(notes: [
        (
          id: const NoteId('n1'),
          pitch: const Pitch(step: Step.c, octave: 4),
          offset: Fraction.zero,
        ),
      ]);
      final tree = calc.calculate(score);
      final note = tree.systems.first.measures.first.voices.first.notes.first;
      expect(note.staffLine, equals(-2));
    });

    test('single quarter G4 in treble clef → staffLine 2', () {
      final score = _quarterNoteScore(notes: [
        (
          id: const NoteId('n1'),
          pitch: const Pitch(step: Step.g, octave: 4),
          offset: Fraction.zero,
        ),
      ]);
      final tree = calc.calculate(score);
      final note = tree.systems.first.measures.first.voices.first.notes.first;
      expect(note.staffLine, equals(2));
    });

    test('single quarter C4 in bass clef → staffLine 3', () {
      final score = _quarterNoteScore(
        clef: Clef.bass,
        notes: [
          (
            id: const NoteId('n1'),
            pitch: const Pitch(step: Step.c, octave: 3),
            offset: Fraction.zero,
          ),
        ],
      );
      final tree = calc.calculate(score);
      final note = tree.systems.first.measures.first.voices.first.notes.first;
      expect(note.staffLine, equals(3));
    });

    test('single voice → stem direction down', () {
      final score = _quarterNoteScore(notes: [
        (
          id: const NoteId('n1'),
          pitch: const Pitch(step: Step.c, octave: 4),
          offset: Fraction.zero,
        ),
      ]);
      final note = calc.calculate(score).systems.first.measures.first.voices.first.notes.first;
      expect(note.stemDirection, equals(StemDirection.down));
    });

    test('note with sharp → AccidentalLayout added', () {
      final score = _quarterNoteScore(notes: [
        (
          id: const NoteId('n1'),
          pitch: const Pitch(step: Step.c, alter: 1.0, octave: 4),
          offset: Fraction.zero,
        ),
      ]);
      final note = calc.calculate(score).systems.first.measures.first.voices.first.notes.first;
      expect(note.accidentals, hasLength(1));
      expect(note.accidentals.first.type, equals('sharp'));
    });

    test('rest event produces RestLayout', () {
      final score = Score(
        id: const ScoreId('s'),
        parts: IList([
          Part(
            id: const PartId('p1'),
            name: 'Piano',
            staves: IList([
              Staff(
                id: const StaffId('s1'),
                measures: IMap({
                  1: Measure(
                    id: const MeasureId('m1'),
                    voices: IMap({
                      const VoiceId('v1'): Voice(
                        id: const VoiceId('v1'),
                        events: IList([
                          RestEvent(
                            id: const RestId('r1'),
                            offset: Fraction.zero,
                            noteValue: NoteValue(noteType: NoteType.whole),
                            isFullMeasure: true,
                          ),
                        ]),
                      ),
                    }),
                  ),
                }),
              ),
            ]),
          ),
        ]),
        measureHeaders: IList([
          MeasureHeader(
            measureNumber: 1,
            timeSignature: const TimeSignature(beats: 4, beatType: 4),
            keySignature: const KeySignature(fifths: 0),
          ),
        ]),
      );
      final voice = calc.calculate(score).systems.first.measures.first.voices.first;
      expect(voice.rests, hasLength(1));
      expect(voice.rests.first.staffLine, equals(4)); // center, single voice
    });

    test('two voices with same pitch → shared notehead flagged', () {
      const v1 = VoiceId('v1');
      const v2 = VoiceId('v2');
      final score = Score(
        id: const ScoreId('s'),
        parts: IList([
          Part(
            id: const PartId('p1'),
            name: 'Piano',
            staves: IList([
              Staff(
                id: const StaffId('s1'),
                measures: IMap({
                  1: Measure(
                    id: const MeasureId('m1'),
                    voices: IMap({
                      v1: Voice(
                        id: v1,
                        priority: 0,
                        events: IList([
                          NoteEvent(
                            id: const NoteId('n1'),
                            offset: Fraction.zero,
                            noteValue: NoteValue(noteType: NoteType.quarter),
                            pitch: const Pitch(step: Step.c, octave: 4),
                          ),
                        ]),
                      ),
                      v2: Voice(
                        id: v2,
                        priority: 1,
                        events: IList([
                          NoteEvent(
                            id: const NoteId('n2'),
                            offset: Fraction.zero,
                            noteValue: NoteValue(noteType: NoteType.quarter),
                            pitch: const Pitch(step: Step.c, octave: 4),
                          ),
                        ]),
                      ),
                    }),
                  ),
                }),
              ),
            ]),
          ),
        ]),
        measureHeaders: IList([
          MeasureHeader(
            measureNumber: 1,
            timeSignature: const TimeSignature(beats: 4, beatType: 4),
            keySignature: const KeySignature(fifths: 0),
          ),
        ]),
      );

      final measures = calc.calculate(score).systems.first.measures.first.voices;
      final allNotes = measures.expand((v) => v.notes).toList();
      expect(allNotes.every((n) => n.isSharedNotehead), isTrue);
    });

    test('LayoutTree is deterministic — same score same output', () {
      final score = _quarterNoteScore(notes: [
        (
          id: const NoteId('n1'),
          pitch: const Pitch(step: Step.c, octave: 4),
          offset: Fraction.zero,
        ),
      ]);
      expect(calc.calculate(score), equals(calc.calculate(score)));
    });
  });
}
