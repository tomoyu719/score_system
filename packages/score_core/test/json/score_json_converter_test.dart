import 'package:fast_immutable_collections/fast_immutable_collections.dart';
import 'package:score_core/score_core.dart';
import 'package:test/test.dart';

void main() {
  const converter = ScoreJsonConverter();

  group('ScoreJsonConverter', () {
    test('Pitch roundtrip', () {
      final original = Pitch(step: Step.c, alter: 1.0, octave: 4);
      final map = converter.scoreToMap(
        Score(
          id: ScoreId('s'),
          parts: IList([
            Part(
              id: PartId('p'),
              name: 'P',
              staves: IList([
                Staff(
                  id: StaffId('st'),
                  measures: IMap({
                    1: Measure(
                      id: MeasureId('m'),
                      voices: IMap({
                        VoiceId('v'): Voice(
                          id: VoiceId('v'),
                          events: IList([
                            NoteEvent(
                              id: NoteId('n'),
                              offset: Fraction.zero,
                              noteValue: NoteValue(noteType: NoteType.quarter),
                              pitch: original,
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
        ),
      );
      final decoded = converter.scoreFromMap(map);
      final decodedPitch = (decoded.parts[0].staves[0].measures[1]!
          .voices[VoiceId('v')]!.events[0] as NoteEvent).pitch;
      expect(decodedPitch, equals(original));
    });

    test('NoteValue undotted roundtrip', () {
      final original = NoteValue(noteType: NoteType.quarter);
      final score = Score(
        id: ScoreId('s'),
        parts: IList([
          Part(
            id: PartId('p'),
            name: 'P',
            staves: IList([
              Staff(
                id: StaffId('st'),
                measures: IMap({
                  1: Measure(
                    id: MeasureId('m'),
                    voices: IMap({
                      VoiceId('v'): Voice(
                        id: VoiceId('v'),
                        events: IList([
                          NoteEvent(
                            id: NoteId('n'),
                            offset: Fraction.zero,
                            noteValue: original,
                            pitch: Pitch(step: Step.c, octave: 4),
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
      );
      final decoded = converter.scoreFromMap(converter.scoreToMap(score));
      final nv = (decoded.parts[0].staves[0].measures[1]!
          .voices[VoiceId('v')]!.events[0] as NoteEvent).noteValue;
      expect(nv, equals(original));
    });

    test('NoteValue dotted roundtrip', () {
      final original = NoteValue(noteType: NoteType.half, dots: 1);
      final score = Score(
        id: ScoreId('s'),
        parts: IList([
          Part(
            id: PartId('p'),
            name: 'P',
            staves: IList([
              Staff(
                id: StaffId('st'),
                measures: IMap({
                  1: Measure(
                    id: MeasureId('m'),
                    voices: IMap({
                      VoiceId('v'): Voice(
                        id: VoiceId('v'),
                        events: IList([
                          NoteEvent(
                            id: NoteId('n'),
                            offset: Fraction.zero,
                            noteValue: original,
                            pitch: Pitch(step: Step.c, octave: 4),
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
      );
      final decoded = converter.scoreFromMap(converter.scoreToMap(score));
      final nv = (decoded.parts[0].staves[0].measures[1]!
          .voices[VoiceId('v')]!.events[0] as NoteEvent).noteValue;
      expect(nv, equals(original));
    });

    test('NoteValue with tupletRatio roundtrip', () {
      final original = NoteValue(
        noteType: NoteType.eighth,
        tupletRatio: Fraction(2, 3),
      );
      final score = Score(
        id: ScoreId('s'),
        parts: IList([
          Part(
            id: PartId('p'),
            name: 'P',
            staves: IList([
              Staff(
                id: StaffId('st'),
                measures: IMap({
                  1: Measure(
                    id: MeasureId('m'),
                    voices: IMap({
                      VoiceId('v'): Voice(
                        id: VoiceId('v'),
                        events: IList([
                          NoteEvent(
                            id: NoteId('n'),
                            offset: Fraction.zero,
                            noteValue: original,
                            pitch: Pitch(step: Step.c, octave: 4),
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
      );
      final decoded = converter.scoreFromMap(converter.scoreToMap(score));
      final nv = (decoded.parts[0].staves[0].measures[1]!
          .voices[VoiceId('v')]!.events[0] as NoteEvent).noteValue;
      expect(nv, equals(original));
    });

    test('NoteEvent roundtrip', () {
      final original = NoteEvent(
        id: NoteId('note-1'),
        offset: Fraction(1, 4),
        noteValue: NoteValue(noteType: NoteType.quarter),
        pitch: Pitch(step: Step.g, octave: 4),
        isGrace: false,
        articulations: IList([Articulation(type: ArticulationType.staccato)]),
        dynamics: IList([Dynamic(type: DynamicType.mf, placement: Placement.below)]),
        lyrics: IList([Lyric(text: 'la', syllabic: Syllabic.single, number: 1)]),
        fingering: Fingering(value: 2),
      );
      final score = Score(
        id: ScoreId('s'),
        parts: IList([
          Part(
            id: PartId('p'),
            name: 'P',
            staves: IList([
              Staff(
                id: StaffId('st'),
                measures: IMap({
                  1: Measure(
                    id: MeasureId('m'),
                    voices: IMap({
                      VoiceId('v'): Voice(
                        id: VoiceId('v'),
                        events: IList([original]),
                      ),
                    }),
                  ),
                }),
              ),
            ]),
          ),
        ]),
      );
      final decoded = converter.scoreFromMap(converter.scoreToMap(score));
      final d = decoded.parts[0].staves[0].measures[1]!
          .voices[VoiceId('v')]!.events[0] as NoteEvent;
      expect(d.id, equals(original.id));
      expect(d.offset, equals(original.offset));
      expect(d.noteValue, equals(original.noteValue));
      expect(d.pitch, equals(original.pitch));
      expect(d.isGrace, equals(original.isGrace));
      expect(d.articulations, equals(original.articulations));
      expect(d.dynamics, equals(original.dynamics));
      expect(d.lyrics, equals(original.lyrics));
      expect(d.fingering, equals(original.fingering));
    });

    test('RestEvent roundtrip', () {
      final original = RestEvent(
        id: RestId('rest-1'),
        offset: Fraction.zero,
        noteValue: NoteValue(noteType: NoteType.whole),
        isFullMeasure: true,
      );
      final score = Score(
        id: ScoreId('s'),
        parts: IList([
          Part(
            id: PartId('p'),
            name: 'P',
            staves: IList([
              Staff(
                id: StaffId('st'),
                measures: IMap({
                  1: Measure(
                    id: MeasureId('m'),
                    voices: IMap({
                      VoiceId('v'): Voice(
                        id: VoiceId('v'),
                        events: IList([original]),
                      ),
                    }),
                  ),
                }),
              ),
            ]),
          ),
        ]),
      );
      final decoded = converter.scoreFromMap(converter.scoreToMap(score));
      final d = decoded.parts[0].staves[0].measures[1]!
          .voices[VoiceId('v')]!.events[0] as RestEvent;
      expect(d.id, equals(original.id));
      expect(d.offset, equals(original.offset));
      expect(d.noteValue, equals(original.noteValue));
      expect(d.isFullMeasure, equals(original.isFullMeasure));
    });

    test('ChordEvent roundtrip', () {
      final note = NoteEvent(
        id: NoteId('note-chord-1'),
        offset: Fraction.zero,
        noteValue: NoteValue(noteType: NoteType.quarter),
        pitch: Pitch(step: Step.e, octave: 4),
      );
      final original = ChordEvent(
        id: ChordId('chord-1'),
        offset: Fraction.zero,
        noteValue: NoteValue(noteType: NoteType.quarter),
        notes: IList([note]),
        articulations: IList([Articulation(type: ArticulationType.accent)]),
        dynamics: IList([Dynamic(type: DynamicType.f)]),
      );
      final score = Score(
        id: ScoreId('s'),
        parts: IList([
          Part(
            id: PartId('p'),
            name: 'P',
            staves: IList([
              Staff(
                id: StaffId('st'),
                measures: IMap({
                  1: Measure(
                    id: MeasureId('m'),
                    voices: IMap({
                      VoiceId('v'): Voice(
                        id: VoiceId('v'),
                        events: IList([original]),
                      ),
                    }),
                  ),
                }),
              ),
            ]),
          ),
        ]),
      );
      final decoded = converter.scoreFromMap(converter.scoreToMap(score));
      final d = decoded.parts[0].staves[0].measures[1]!
          .voices[VoiceId('v')]!.events[0] as ChordEvent;
      expect(d.id, equals(original.id));
      expect(d.offset, equals(original.offset));
      expect(d.noteValue, equals(original.noteValue));
      expect(d.notes.length, equals(1));
      expect(d.notes[0].id, equals(note.id));
      expect(d.articulations, equals(original.articulations));
      expect(d.dynamics, equals(original.dynamics));
    });

    test('Voice roundtrip', () {
      final event = RestEvent(
        id: RestId('rest-v1'),
        offset: Fraction.zero,
        noteValue: NoteValue(noteType: NoteType.quarter),
      );
      final original = Voice(
        id: VoiceId('voice-1'),
        events: IList([event]),
      );
      final score = Score(
        id: ScoreId('s'),
        parts: IList([
          Part(
            id: PartId('p'),
            name: 'P',
            staves: IList([
              Staff(
                id: StaffId('st'),
                measures: IMap({
                  1: Measure(
                    id: MeasureId('m'),
                    voices: IMap({VoiceId('voice-1'): original}),
                  ),
                }),
              ),
            ]),
          ),
        ]),
      );
      final decoded = converter.scoreFromMap(converter.scoreToMap(score));
      final dv = decoded.parts[0].staves[0].measures[1]!.voices[VoiceId('voice-1')]!;
      expect(dv.id, equals(original.id));
      expect(dv.events.length, equals(1));
      expect((dv.events[0] as RestEvent).id, equals(event.id));
    });

    test('Measure roundtrip', () {
      final voice = Voice(
        id: VoiceId('v1'),
        events: IList([
          RestEvent(
            id: RestId('r1'),
            offset: Fraction.zero,
            noteValue: NoteValue(noteType: NoteType.whole),
            isFullMeasure: true,
          ),
        ]),
      );
      final original = Measure(
        id: MeasureId('m1'),
        voices: IMap({VoiceId('v1'): voice}),
      );
      final score = Score(
        id: ScoreId('s'),
        parts: IList([
          Part(
            id: PartId('p'),
            name: 'P',
            staves: IList([
              Staff(
                id: StaffId('st'),
                measures: IMap({1: original}),
              ),
            ]),
          ),
        ]),
      );
      final decoded = converter.scoreFromMap(converter.scoreToMap(score));
      final dm = decoded.parts[0].staves[0].measures[1]!;
      expect(dm.id, equals(original.id));
      expect(dm.voices.length, equals(1));
      expect(dm.voices[VoiceId('v1')]?.id, equals(VoiceId('v1')));
    });

    test('Staff roundtrip', () {
      final measure = Measure(id: MeasureId('m1'), voices: IMap({}));
      final original = Staff(
        id: StaffId('s1'),
        staffType: StaffType.standard,
        measures: IMap({1: measure}),
      );
      final score = Score(
        id: ScoreId('s'),
        parts: IList([
          Part(
            id: PartId('p'),
            name: 'P',
            staves: IList([original]),
          ),
        ]),
      );
      final decoded = converter.scoreFromMap(converter.scoreToMap(score));
      final ds = decoded.parts[0].staves[0];
      expect(ds.id, equals(original.id));
      expect(ds.staffType, equals(original.staffType));
      expect(ds.measures.length, equals(1));
      expect(ds.measures[1]?.id, equals(measure.id));
    });

    test('Part roundtrip', () {
      final staff = Staff(
        id: StaffId('s1'),
        staffType: StaffType.tab,
        measures: IMap({}),
      );
      final original = Part(
        id: PartId('p1'),
        name: 'Violin',
        shortName: 'Vln.',
        staves: IList([staff]),
      );
      final score = Score(
        id: ScoreId('s'),
        parts: IList([original]),
      );
      final decoded = converter.scoreFromMap(converter.scoreToMap(score));
      final dp = decoded.parts[0];
      expect(dp.id, equals(original.id));
      expect(dp.name, equals(original.name));
      expect(dp.shortName, equals(original.shortName));
      expect(dp.staves.length, equals(1));
      expect(dp.staves[0].id, equals(staff.id));
      expect(dp.staves[0].staffType, equals(StaffType.tab));
    });

    test('TimeSignature roundtrip', () {
      final original = TimeSignature(beats: 6, beatType: 8);
      final header = MeasureHeader(
        measureNumber: 1,
        timeSignature: original,
        keySignature: KeySignature(fifths: 0),
      );
      final score = Score(
        id: ScoreId('s'),
        measureHeaders: IList([header]),
      );
      final decoded = converter.scoreFromMap(converter.scoreToMap(score));
      expect(decoded.measureHeaders[0].timeSignature, equals(original));
    });

    test('KeySignature roundtrip', () {
      final original = KeySignature(fifths: -3, mode: Mode.minor);
      final header = MeasureHeader(
        measureNumber: 1,
        timeSignature: TimeSignature(beats: 4, beatType: 4),
        keySignature: original,
      );
      final score = Score(
        id: ScoreId('s'),
        measureHeaders: IList([header]),
      );
      final decoded = converter.scoreFromMap(converter.scoreToMap(score));
      expect(decoded.measureHeaders[0].keySignature, equals(original));
    });

    test('Tempo roundtrip', () {
      final original = Tempo(bpm: 120.0, beatUnit: NoteType.quarter);
      final header = MeasureHeader(
        measureNumber: 1,
        timeSignature: TimeSignature(beats: 4, beatType: 4),
        keySignature: KeySignature(fifths: 0),
        tempo: original,
      );
      final score = Score(
        id: ScoreId('s'),
        measureHeaders: IList([header]),
      );
      final decoded = converter.scoreFromMap(converter.scoreToMap(score));
      expect(decoded.measureHeaders[0].tempo, equals(original));
    });

    test('MeasureHeader with tempo roundtrip', () {
      final original = MeasureHeader(
        measureNumber: 1,
        timeSignature: TimeSignature(beats: 4, beatType: 4),
        keySignature: KeySignature(fifths: 0),
        tempo: Tempo(bpm: 96.0),
        barlineStart: BarlineType.repeatStart,
        barlineEnd: BarlineType.regular,
      );
      final score = Score(
        id: ScoreId('s'),
        measureHeaders: IList([original]),
      );
      final decoded = converter.scoreFromMap(converter.scoreToMap(score));
      expect(decoded.measureHeaders[0], equals(original));
    });

    test('MeasureHeader without tempo roundtrip', () {
      final original = MeasureHeader(
        measureNumber: 3,
        timeSignature: TimeSignature(beats: 3, beatType: 4),
        keySignature: KeySignature(fifths: 2, mode: Mode.major),
        barlineStart: BarlineType.regular,
        barlineEnd: BarlineType.finalBar,
      );
      final score = Score(
        id: ScoreId('s'),
        measureHeaders: IList([original]),
      );
      final decoded = converter.scoreFromMap(converter.scoreToMap(score));
      expect(decoded.measureHeaders[0], equals(original));
      expect(decoded.measureHeaders[0].tempo, isNull);
    });

    test('BeamGroup roundtrip', () {
      final original = BeamGroup(
        id: BeamGroupId('bg1'),
        noteIds: IList([NoteId('n1'), NoteId('n2'), NoteId('n3')]),
      );
      final part = Part(
        id: PartId('p1'),
        name: 'Piano',
        beamGroups: IList([original]),
      );
      final score = Score(id: ScoreId('s'), parts: IList([part]));
      final decoded = converter.scoreFromMap(converter.scoreToMap(score));
      expect(decoded.parts[0].beamGroups[0].id, equals(original.id));
      expect(decoded.parts[0].beamGroups[0].noteIds, equals(original.noteIds));
    });

    test('Slur with placement roundtrip', () {
      final original = Slur(
        id: SlurId('slur1'),
        startNoteId: NoteId('n1'),
        endNoteId: NoteId('n2'),
        placement: Placement.above,
      );
      final part = Part(
        id: PartId('p1'),
        name: 'Piano',
        slurs: IList([original]),
      );
      final score = Score(id: ScoreId('s'), parts: IList([part]));
      final decoded = converter.scoreFromMap(converter.scoreToMap(score));
      expect(decoded.parts[0].slurs[0].id, equals(original.id));
      expect(decoded.parts[0].slurs[0].startNoteId, equals(original.startNoteId));
      expect(decoded.parts[0].slurs[0].endNoteId, equals(original.endNoteId));
      expect(decoded.parts[0].slurs[0].placement, equals(Placement.above));
    });

    test('Tie roundtrip', () {
      final original = Tie(
        id: TieId('tie1'),
        startNoteId: NoteId('n1'),
        endNoteId: NoteId('n2'),
      );
      final part = Part(
        id: PartId('p1'),
        name: 'Piano',
        ties: IList([original]),
      );
      final score = Score(id: ScoreId('s'), parts: IList([part]));
      final decoded = converter.scoreFromMap(converter.scoreToMap(score));
      expect(decoded.parts[0].ties[0].id, equals(original.id));
      expect(decoded.parts[0].ties[0].startNoteId, equals(original.startNoteId));
      expect(decoded.parts[0].ties[0].endNoteId, equals(original.endNoteId));
    });

    test('Tuplet roundtrip', () {
      final original = Tuplet(
        id: TupletId('tup1'),
        noteIds: IList([NoteId('n1'), NoteId('n2'), NoteId('n3')]),
        ratio: Fraction(2, 3),
      );
      final part = Part(
        id: PartId('p1'),
        name: 'Piano',
        tuplets: IList([original]),
      );
      final score = Score(id: ScoreId('s'), parts: IList([part]));
      final decoded = converter.scoreFromMap(converter.scoreToMap(score));
      expect(decoded.parts[0].tuplets[0].id, equals(original.id));
      expect(decoded.parts[0].tuplets[0].noteIds, equals(original.noteIds));
      expect(decoded.parts[0].tuplets[0].ratio, equals(original.ratio));
    });

    test('Score empty roundtrip', () {
      final original = Score(id: ScoreId('score-empty'));
      final decoded = converter.scoreFromMap(converter.scoreToMap(original));
      expect(decoded.id, equals(original.id));
      expect(decoded.title, equals(''));
      expect(decoded.composer, equals(''));
      expect(decoded.parts, isEmpty);
      expect(decoded.measureHeaders, isEmpty);
    });

    test('Score with parts and headers roundtrip', () {
      final staff = Staff(
        id: StaffId('s1'),
        staffType: StaffType.standard,
        measures: IMap({
          1: Measure(
            id: MeasureId('m1'),
            voices: IMap({
              VoiceId('v1'): Voice(
                id: VoiceId('v1'),
                events: IList([
                  RestEvent(
                    id: RestId('r1'),
                    offset: Fraction.zero,
                    noteValue: NoteValue(noteType: NoteType.whole),
                    isFullMeasure: true,
                  ),
                ]),
              ),
            }),
          ),
        }),
      );
      final beamGroup = BeamGroup(
        id: BeamGroupId('bg1'),
        noteIds: IList([NoteId('n1'), NoteId('n2')]),
      );
      final slur = Slur(
        id: SlurId('sl1'),
        startNoteId: NoteId('n1'),
        endNoteId: NoteId('n2'),
      );
      final tie = Tie(
        id: TieId('t1'),
        startNoteId: NoteId('n3'),
        endNoteId: NoteId('n4'),
      );
      final tuplet = Tuplet(
        id: TupletId('tup1'),
        noteIds: IList([NoteId('n5'), NoteId('n6'), NoteId('n7')]),
        ratio: Fraction(2, 3),
      );
      final part = Part(
        id: PartId('p1'),
        name: 'Piano',
        shortName: 'Pno.',
        staves: IList([staff]),
        beamGroups: IList([beamGroup]),
        slurs: IList([slur]),
        ties: IList([tie]),
        tuplets: IList([tuplet]),
      );
      final header = MeasureHeader(
        measureNumber: 1,
        timeSignature: TimeSignature(beats: 4, beatType: 4),
        keySignature: KeySignature(fifths: 0),
        tempo: Tempo(bpm: 120.0),
        barlineStart: BarlineType.regular,
        barlineEnd: BarlineType.finalBar,
      );
      final original = Score(
        id: ScoreId('score-1'),
        title: 'Test Score',
        composer: 'Test Composer',
        parts: IList([part]),
        measureHeaders: IList([header]),
      );
      final decoded = converter.scoreFromMap(converter.scoreToMap(original));
      expect(decoded.id, equals(original.id));
      expect(decoded.title, equals('Test Score'));
      expect(decoded.composer, equals('Test Composer'));
      expect(decoded.parts.length, equals(1));
      expect(decoded.parts[0].id, equals(PartId('p1')));
      expect(
        decoded.parts[0].staves[0].measures[1]?.voices[VoiceId('v1')]?.events.length,
        equals(1),
      );
      expect(decoded.measureHeaders.length, equals(1));
      expect(decoded.measureHeaders[0], equals(header));
      expect(decoded.parts[0].beamGroups.length, equals(1));
      expect(decoded.parts[0].beamGroups[0].id, equals(beamGroup.id));
      expect(decoded.parts[0].slurs.length, equals(1));
      expect(decoded.parts[0].slurs[0].id, equals(slur.id));
      expect(decoded.parts[0].ties.length, equals(1));
      expect(decoded.parts[0].ties[0].id, equals(tie.id));
      expect(decoded.parts[0].tuplets.length, equals(1));
      expect(decoded.parts[0].tuplets[0].id, equals(tuplet.id));
    });
  });
}
