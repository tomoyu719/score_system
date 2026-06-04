import 'package:fast_immutable_collections/fast_immutable_collections.dart';
import 'package:score_core/score_core.dart';
import 'package:score_layout/score_layout.dart';
import 'package:test/test.dart';

import 'golden_test_helper.dart';

void main() {
  final calc = LayoutCalculator();

  test('simple_quarter_notes', () {
    final score = Score(
      id: const ScoreId('s'),
      parts: IList([
        Part(
          id: const PartId('p1'),
          name: 'Piano',
          staves: IList([
            Staff(
              id: const StaffId('s1'),
              clef: Clef.treble,
              measures: IMap({
                1: Measure(
                  id: const MeasureId('m1'),
                  voices: IMap({
                    const VoiceId('v1'): Voice(
                      id: const VoiceId('v1'),
                      events: IList([
                        NoteEvent(
                          id: const NoteId('n1'),
                          offset: Fraction.zero,
                          noteValue: NoteValue(noteType: NoteType.quarter),
                          pitch: const Pitch(step: Step.c, octave: 4),
                        ),
                        NoteEvent(
                          id: const NoteId('n2'),
                          offset: Fraction(1, 4),
                          noteValue: NoteValue(noteType: NoteType.quarter),
                          pitch: const Pitch(step: Step.d, octave: 4),
                        ),
                        NoteEvent(
                          id: const NoteId('n3'),
                          offset: Fraction(2, 4),
                          noteValue: NoteValue(noteType: NoteType.quarter),
                          pitch: const Pitch(step: Step.e, octave: 4),
                        ),
                        NoteEvent(
                          id: const NoteId('n4'),
                          offset: Fraction(3, 4),
                          noteValue: NoteValue(noteType: NoteType.quarter),
                          pitch: const Pitch(step: Step.f, octave: 4),
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

    expectMatchesGolden('simple_quarter_notes', calc.calculate(score));
  });

  test('chord_with_accidentals', () {
    final score = Score(
      id: const ScoreId('s'),
      parts: IList([
        Part(
          id: const PartId('p1'),
          name: 'Piano',
          staves: IList([
            Staff(
              id: const StaffId('s1'),
              clef: Clef.treble,
              measures: IMap({
                1: Measure(
                  id: const MeasureId('m1'),
                  voices: IMap({
                    const VoiceId('v1'): Voice(
                      id: const VoiceId('v1'),
                      events: IList([
                        ChordEvent(
                          id: const ChordId('c1'),
                          offset: Fraction.zero,
                          noteValue: NoteValue(noteType: NoteType.quarter),
                          notes: IList([
                            NoteEvent(
                              id: const NoteId('n1'),
                              offset: Fraction.zero,
                              noteValue: NoteValue(noteType: NoteType.quarter),
                              pitch: const Pitch(
                                  step: Step.c, alter: 1.0, octave: 4),
                            ),
                            NoteEvent(
                              id: const NoteId('n2'),
                              offset: Fraction.zero,
                              noteValue: NoteValue(noteType: NoteType.quarter),
                              pitch: const Pitch(
                                  step: Step.e, alter: -1.0, octave: 4),
                            ),
                          ]),
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

    expectMatchesGolden('chord_with_accidentals', calc.calculate(score));
  });

  test('n_voice_layout', () {
    final score = Score(
      id: const ScoreId('s'),
      parts: IList([
        Part(
          id: const PartId('p1'),
          name: 'Piano',
          staves: IList([
            Staff(
              id: const StaffId('s1'),
              clef: Clef.treble,
              measures: IMap({
                1: Measure(
                  id: const MeasureId('m1'),
                  voices: IMap({
                    const VoiceId('v1'): Voice(
                      id: const VoiceId('v1'),
                      priority: 0,
                      events: IList([
                        NoteEvent(
                          id: const NoteId('n1'),
                          offset: Fraction.zero,
                          noteValue: NoteValue(noteType: NoteType.quarter),
                          pitch: const Pitch(step: Step.c, octave: 5),
                        ),
                      ]),
                    ),
                    const VoiceId('v2'): Voice(
                      id: const VoiceId('v2'),
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

    expectMatchesGolden('n_voice_layout', calc.calculate(score));
  });
}
