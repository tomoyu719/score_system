import 'package:fast_immutable_collections/fast_immutable_collections.dart';
import 'package:score_core/score_core.dart';
import 'package:score_layout/score_layout.dart';
import 'package:test/test.dart';

Score makeSimpleScore({
  List<MusicEvent> events = const [],
  int measureNumber = 1,
}) {
  const partId = PartId('part-1');
  const staffId = StaffId('staff-1');
  const voiceId = VoiceId('voice-1');

  final voice = Voice(id: voiceId, events: IList(events));
  final measure = Measure(
    id: const MeasureId('measure-1'),
    voices: IMap({voiceId: voice}),
  );
  final staff = Staff(
    id: staffId,
    measures: IMap({measureNumber: measure}),
  );
  final part = Part(
    id: partId,
    name: 'Piano',
    staves: IList([staff]),
  );

  return Score(
    id: const ScoreId('score-1'),
    parts: IList([part]),
    measureHeaders: IList([
      MeasureHeader(
        measureNumber: measureNumber,
        timeSignature: const TimeSignature(beats: 4, beatType: 4),
        keySignature: const KeySignature(fifths: 0),
      ),
    ]),
  );
}

void main() {
  const engine = LayoutEngine();

  group('LayoutEngine.layout', () {
    test('empty score → empty LayoutTree parts', () {
      final score = Score(
        id: const ScoreId('score-0'),
        parts: const IListConst([]),
      );
      final tree = engine.layout(score);
      expect(tree.parts, isEmpty);
    });

    test('score with 1 note → LayoutTree has 1 NoteheadElement', () {
      final score = makeSimpleScore(events: [
        NoteEvent(
          id: const NoteId('n1'),
          offset: Fraction.zero,
          noteValue: const NoteValue(noteType: NoteType.quarter),
          pitch: const Pitch(step: Step.c, octave: 4),
        ),
      ]);
      final tree = engine.layout(score);
      final noteheads = tree.allElements().whereType<NoteheadElement>();
      expect(noteheads.length, 1);
    });

    test('score with rest → LayoutTree has 1 RestElement', () {
      final score = makeSimpleScore(events: [
        RestEvent(
          id: const RestId('r1'),
          offset: Fraction.zero,
          noteValue: const NoteValue(noteType: NoteType.quarter),
        ),
      ]);
      final tree = engine.layout(score);
      final rests = tree.allElements().whereType<RestElement>();
      expect(rests.length, 1);
    });

    test('note with sharp → has AccidentalElement', () {
      final score = makeSimpleScore(events: [
        NoteEvent(
          id: const NoteId('n1'),
          offset: Fraction.zero,
          noteValue: const NoteValue(noteType: NoteType.quarter),
          pitch: const Pitch(step: Step.f, octave: 4, alter: 1.0),
        ),
      ]);
      final tree = engine.layout(score);
      final accidentals = tree.allElements().whereType<AccidentalElement>();
      expect(accidentals.length, 1);
      expect(accidentals.first.accidentalType, AccidentalType.sharp);
    });

    test('note with flat → has AccidentalElement of type flat', () {
      final score = makeSimpleScore(events: [
        NoteEvent(
          id: const NoteId('n1'),
          offset: Fraction.zero,
          noteValue: const NoteValue(noteType: NoteType.quarter),
          pitch: const Pitch(step: Step.b, octave: 4, alter: -1.0),
        ),
      ]);
      final tree = engine.layout(score);
      final accidentals = tree.allElements().whereType<AccidentalElement>();
      expect(accidentals.length, 1);
      expect(accidentals.first.accidentalType, AccidentalType.flat);
    });

    test('quarter note creates StemElement', () {
      final score = makeSimpleScore(events: [
        NoteEvent(
          id: const NoteId('n1'),
          offset: Fraction.zero,
          noteValue: const NoteValue(noteType: NoteType.quarter),
          pitch: const Pitch(step: Step.c, octave: 4),
        ),
      ]);
      final tree = engine.layout(score);
      final stems = tree.allElements().whereType<StemElement>();
      expect(stems.length, 1);
    });

    test('whole note does NOT create StemElement', () {
      final score = makeSimpleScore(events: [
        NoteEvent(
          id: const NoteId('n1'),
          offset: Fraction.zero,
          noteValue: const NoteValue(noteType: NoteType.whole),
          pitch: const Pitch(step: Step.c, octave: 4),
        ),
      ]);
      final tree = engine.layout(score);
      final stems = tree.allElements().whereType<StemElement>();
      expect(stems, isEmpty);
    });

    test('chord event creates noteheads for each chord note', () {
      final score = makeSimpleScore(events: [
        ChordEvent(
          id: const ChordId('ch1'),
          offset: Fraction.zero,
          noteValue: const NoteValue(noteType: NoteType.quarter),
          notes: IList([
            NoteEvent(
              id: const NoteId('n1'),
              offset: Fraction.zero,
              noteValue: const NoteValue(noteType: NoteType.quarter),
              pitch: const Pitch(step: Step.c, octave: 4),
            ),
            NoteEvent(
              id: const NoteId('n2'),
              offset: Fraction.zero,
              noteValue: const NoteValue(noteType: NoteType.quarter),
              pitch: const Pitch(step: Step.e, octave: 4),
            ),
          ]),
        ),
      ]);
      final tree = engine.layout(score);
      final noteheads = tree.allElements().whereType<NoteheadElement>();
      expect(noteheads.length, 2);
    });
  });

  group('LayoutEngine.relayout', () {
    test('relayout only changes the target measure', () {
      final initialEvents = [
        NoteEvent(
          id: const NoteId('n1'),
          offset: Fraction.zero,
          noteValue: const NoteValue(noteType: NoteType.quarter),
          pitch: const Pitch(step: Step.c, octave: 4),
        ),
      ];

      const partId = PartId('part-1');
      const staffId = StaffId('staff-1');
      const voiceId = VoiceId('voice-1');

      final voice1 = Voice(
        id: voiceId,
        events: IList(initialEvents),
      );
      final voice2 = Voice(
        id: voiceId,
        events: IList([
          NoteEvent(
            id: const NoteId('n2'),
            offset: Fraction.zero,
            noteValue: const NoteValue(noteType: NoteType.quarter),
            pitch: const Pitch(step: Step.d, octave: 4),
          ),
        ]),
      );
      final staff = Staff(
        id: staffId,
        measures: IMap({
          1: Measure(
            id: const MeasureId('m1'),
            voices: IMap({voiceId: voice1}),
          ),
          2: Measure(
            id: const MeasureId('m2'),
            voices: IMap({voiceId: voice2}),
          ),
        }),
      );
      final part = Part(
        id: partId,
        name: 'Piano',
        staves: IList([staff]),
      );
      final score = Score(
        id: const ScoreId('score-1'),
        parts: IList([part]),
        measureHeaders: IList([
          MeasureHeader(
            measureNumber: 1,
            timeSignature: const TimeSignature(beats: 4, beatType: 4),
            keySignature: const KeySignature(fifths: 0),
          ),
          MeasureHeader(
            measureNumber: 2,
            timeSignature: const TimeSignature(beats: 4, beatType: 4),
            keySignature: const KeySignature(fifths: 0),
          ),
        ]),
      );

      final original = engine.layout(score);

      // Modify measure 1: add another note
      final updatedVoice1 = voice1.copyWith(
        events: voice1.events.add(
          NoteEvent(
            id: const NoteId('n3'),
            offset: Fraction(1, 4),
            noteValue: const NoteValue(noteType: NoteType.quarter),
            pitch: const Pitch(step: Step.e, octave: 4),
          ),
        ),
      );
      final updatedScore = score.copyWith(
        parts: IList([
          part.copyWith(
            staves: IList([
              staff.copyWith(
                measures: IMap({
                  1: Measure(
                    id: const MeasureId('m1'),
                    voices: IMap({voiceId: updatedVoice1}),
                  ),
                  2: Measure(
                    id: const MeasureId('m2'),
                    voices: IMap({voiceId: voice2}),
                  ),
                }),
              ),
            ]),
          ),
        ]),
      );

      final relaidOut = engine.relayout(original, updatedScore, 1);

      // Measure 1 should now have more elements
      final measure1 =
          relaidOut.findMeasure(partId.value, staffId.value, 1);
      expect(measure1, isNotNull);
      final measure2 =
          relaidOut.findMeasure(partId.value, staffId.value, 2);
      expect(measure2, isNotNull);

      // Measure 2's elements should be the same objects (not relaid out)
      final origMeasure2 = original.findMeasure(partId.value, staffId.value, 2);
      expect(measure2!.elements, origMeasure2!.elements);
    });
  });
}
