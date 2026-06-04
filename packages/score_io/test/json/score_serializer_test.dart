import 'dart:convert';

import 'package:fast_immutable_collections/fast_immutable_collections.dart';
import 'package:score_core/score_core.dart';
import 'package:score_io/score_io.dart';
import 'package:test/test.dart';

void main() {

  Score emptyScore() => Score(
        id: const ScoreId('score-1'),
        title: '',
        composer: '',
      );

  group('ScoreSerializer', () {
    test('empty score roundtrips through toJson/fromJson', () {
      final score = emptyScore();
      final json = ScoreIo.toJsonString(score);
      final restored = ScoreIo.fromJsonString(json);

      expect(restored.id, equals(score.id));
      expect(restored.title, equals(score.title));
      expect(restored.composer, equals(score.composer));
      expect(restored.parts, isEmpty);
      expect(restored.measureHeaders, isEmpty);
    });

    test('title and composer roundtrip', () {
      final score = Score(
        id: const ScoreId('score-2'),
        title: 'Symphony No. 5',
        composer: 'Beethoven',
      );
      final restored = ScoreIo.fromJsonString(ScoreIo.toJsonString(score));
      expect(restored.title, equals('Symphony No. 5'));
      expect(restored.composer, equals('Beethoven'));
    });

    test('MeasureHeader serializes time signature, key signature, barlines', () {
      final header = MeasureHeader(
        measureNumber: 1,
        timeSignature: const TimeSignature(beats: 3, beatType: 4),
        keySignature: const KeySignature(fifths: 2, mode: Mode.major),
        barlineStart: BarlineType.repeatStart,
        barlineEnd: BarlineType.finalBar,
      );
      final score = Score(
        id: const ScoreId('score-3'),
        measureHeaders: IList([header]),
      );
      final restored = ScoreIo.fromJsonString(ScoreIo.toJsonString(score));
      expect(restored.measureHeaders.length, equals(1));
      final h = restored.measureHeaders[0];
      expect(h.measureNumber, equals(1));
      expect(h.timeSignature.beats, equals(3));
      expect(h.timeSignature.beatType, equals(4));
      expect(h.keySignature.fifths, equals(2));
      expect(h.keySignature.mode, equals(Mode.major));
      expect(h.barlineStart, equals(BarlineType.repeatStart));
      expect(h.barlineEnd, equals(BarlineType.finalBar));
    });

    test('MeasureHeader with tempo serializes bpm and beatUnit', () {
      final header = MeasureHeader(
        measureNumber: 1,
        timeSignature: const TimeSignature(beats: 4, beatType: 4),
        keySignature: const KeySignature(fifths: 0),
        tempo: const Tempo(bpm: 120.0, beatUnit: NoteType.quarter),
      );
      final score = Score(
        id: const ScoreId('score-4'),
        measureHeaders: IList([header]),
      );
      final restored = ScoreIo.fromJsonString(ScoreIo.toJsonString(score));
      final h = restored.measureHeaders[0];
      expect(h.tempo, isNotNull);
      expect(h.tempo!.bpm, equals(120.0));
      expect(h.tempo!.beatUnit, equals(NoteType.quarter));
    });

    test('NoteEvent roundtrips through serializer', () {
      final noteId = const NoteId('note-1');
      final voiceId = const VoiceId('v1');
      final note = NoteEvent(
        id: noteId,
        offset: Fraction(0, 1),
        noteValue: const NoteValue(noteType: NoteType.quarter),
        pitch: const Pitch(step: Step.g, alter: 0.0, octave: 4),
        isGrace: true,
      );
      final voice = Voice(
        id: voiceId,
        events: IList([note]),
      );
      final measure = Measure(
        id: const MeasureId('m1'),
        voices: IMap({voiceId: voice}),
      );
      final staff = Staff(
        id: const StaffId('s1'),
        measures: IMap({1: measure}),
      );
      final part = Part(
        id: const PartId('p1'),
        name: 'Violin',
        staves: IList([staff]),
      );
      final score = Score(
        id: const ScoreId('score-5'),
        parts: IList([part]),
      );
      final restored = ScoreIo.fromJsonString(ScoreIo.toJsonString(score));
      final rPart = restored.parts[0];
      final rStaff = rPart.staves[0];
      final rMeasure = rStaff.measures[1]!;
      final rVoice = rMeasure.voices[voiceId]!;
      final rNote = rVoice.events[0] as NoteEvent;
      expect(rNote.id, equals(noteId));
      expect(rNote.pitch.step, equals(Step.g));
      expect(rNote.pitch.octave, equals(4));
      expect(rNote.pitch.alter, equals(0.0));
      expect(rNote.noteValue.noteType, equals(NoteType.quarter));
      expect(rNote.offset, equals(Fraction(0, 1)));
      expect(rNote.isGrace, isTrue);
    });

    test('RestEvent roundtrips', () {
      final voiceId = const VoiceId('v1');
      final rest = RestEvent(
        id: const RestId('rest-1'),
        offset: Fraction(1, 4),
        noteValue: const NoteValue(noteType: NoteType.half),
        isFullMeasure: true,
      );
      final voice = Voice(id: voiceId, events: IList([rest]));
      final measure = Measure(
        id: const MeasureId('m1'),
        voices: IMap({voiceId: voice}),
      );
      final staff = Staff(id: const StaffId('s1'), measures: IMap({1: measure}));
      final part = Part(id: const PartId('p1'), name: 'Piano', staves: IList([staff]));
      final score = Score(id: const ScoreId('score-6'), parts: IList([part]));

      final restored = ScoreIo.fromJsonString(ScoreIo.toJsonString(score));
      final rRest = restored.parts[0].staves[0].measures[1]!.voices[voiceId]!.events[0] as RestEvent;
      expect(rRest.id, equals(const RestId('rest-1')));
      expect(rRest.isFullMeasure, isTrue);
      expect(rRest.offset, equals(Fraction(1, 4)));
      expect(rRest.noteValue.noteType, equals(NoteType.half));
    });

    test('ChordEvent roundtrips with notes', () {
      final voiceId = const VoiceId('v1');
      final note1 = NoteEvent(
        id: const NoteId('n1'),
        offset: Fraction(0, 1),
        noteValue: const NoteValue(noteType: NoteType.quarter),
        pitch: const Pitch(step: Step.c, octave: 4),
      );
      final note2 = NoteEvent(
        id: const NoteId('n2'),
        offset: Fraction(0, 1),
        noteValue: const NoteValue(noteType: NoteType.quarter),
        pitch: const Pitch(step: Step.e, octave: 4),
      );
      final chord = ChordEvent(
        id: const ChordId('chord-1'),
        offset: Fraction(0, 1),
        noteValue: const NoteValue(noteType: NoteType.quarter),
        notes: IList([note1, note2]),
      );
      final voice = Voice(id: voiceId, events: IList([chord]));
      final measure = Measure(
        id: const MeasureId('m1'),
        voices: IMap({voiceId: voice}),
      );
      final staff = Staff(id: const StaffId('s1'), measures: IMap({1: measure}));
      final part = Part(id: const PartId('p1'), name: 'Guitar', staves: IList([staff]));
      final score = Score(id: const ScoreId('score-7'), parts: IList([part]));

      final restored = ScoreIo.fromJsonString(ScoreIo.toJsonString(score));
      final rChord = restored.parts[0].staves[0].measures[1]!.voices[voiceId]!.events[0] as ChordEvent;
      expect(rChord.id, equals(const ChordId('chord-1')));
      expect(rChord.notes.length, equals(2));
      expect(rChord.notes[0].pitch.step, equals(Step.c));
      expect(rChord.notes[1].pitch.step, equals(Step.e));
    });

    test('BeamGroup roundtrips', () {
      final bg = BeamGroup(
        id: const BeamGroupId('bg-1'),
        noteIds: IList([const NoteId('n1'), const NoteId('n2')]),
      );
      final score = Score(
        id: const ScoreId('score-8'),
        parts: IList([
          Part(id: const PartId('p1'), name: 'Piano', beamGroups: IList([bg])),
        ]),
      );
      final restored = ScoreIo.fromJsonString(ScoreIo.toJsonString(score));
      expect(restored.parts[0].beamGroups.length, equals(1));
      final rBg = restored.parts[0].beamGroups[0];
      expect(rBg.id, equals(const BeamGroupId('bg-1')));
      expect(rBg.noteIds[0], equals(const NoteId('n1')));
      expect(rBg.noteIds[1], equals(const NoteId('n2')));
    });

    test('Slur roundtrips', () {
      final slur = Slur(
        id: const SlurId('slur-1'),
        startNoteId: const NoteId('n1'),
        endNoteId: const NoteId('n2'),
        placement: Placement.above,
      );
      final score = Score(
        id: const ScoreId('score-9'),
        parts: IList([
          Part(id: const PartId('p1'), name: 'Piano', slurs: IList([slur])),
        ]),
      );
      final restored = ScoreIo.fromJsonString(ScoreIo.toJsonString(score));
      expect(restored.parts[0].slurs.length, equals(1));
      final rSlur = restored.parts[0].slurs[0];
      expect(rSlur.id, equals(const SlurId('slur-1')));
      expect(rSlur.startNoteId, equals(const NoteId('n1')));
      expect(rSlur.endNoteId, equals(const NoteId('n2')));
      expect(rSlur.placement, equals(Placement.above));
    });

    test('Tie roundtrips', () {
      final tie = Tie(
        id: const TieId('tie-1'),
        startNoteId: const NoteId('n1'),
        endNoteId: const NoteId('n2'),
      );
      final score = Score(
        id: const ScoreId('score-10'),
        parts: IList([
          Part(id: const PartId('p1'), name: 'Piano', ties: IList([tie])),
        ]),
      );
      final restored = ScoreIo.fromJsonString(ScoreIo.toJsonString(score));
      expect(restored.parts[0].ties.length, equals(1));
      final rTie = restored.parts[0].ties[0];
      expect(rTie.id, equals(const TieId('tie-1')));
      expect(rTie.startNoteId, equals(const NoteId('n1')));
      expect(rTie.endNoteId, equals(const NoteId('n2')));
    });

    test('Tuplet roundtrips', () {
      final tuplet = Tuplet(
        id: const TupletId('tuplet-1'),
        noteIds: IList([const NoteId('n1'), const NoteId('n2'), const NoteId('n3')]),
        ratio: Fraction(2, 3),
      );
      final score = Score(
        id: const ScoreId('score-11'),
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
                    tuplets: IList([tuplet]),
                  ),
                }),
              ),
            ]),
          ),
        ]),
      );
      final restored = ScoreIo.fromJsonString(ScoreIo.toJsonString(score));
      final rm = restored.parts[0].staves[0].measures[1]!;
      expect(rm.tuplets.length, equals(1));
      final rTuplet = rm.tuplets[0];
      expect(rTuplet.id, equals(const TupletId('tuplet-1')));
      expect(rTuplet.ratio, equals(Fraction(2, 3)));
      expect(rTuplet.noteIds.length, equals(3));
    });

    test('schema_version is 1 in serialized output', () {
      final score = emptyScore();
      final map = jsonDecode(ScoreIo.toJsonString(score)) as Map<String, Object?>;
      expect(map[r'$schema_version'], equals(1));
    });

    test('NoteEvent with articulations roundtrips', () {
      final voiceId = const VoiceId('v1');
      final note = NoteEvent(
        id: const NoteId('n1'),
        offset: Fraction(0, 1),
        noteValue: const NoteValue(noteType: NoteType.quarter),
        pitch: const Pitch(step: Step.a, octave: 3),
        articulations: IList([
          const Articulation(type: ArticulationType.staccato, placement: Placement.above),
          const Articulation(type: ArticulationType.accent),
        ]),
      );
      final voice = Voice(id: voiceId, events: IList([note]));
      final measure = Measure(id: const MeasureId('m1'), voices: IMap({voiceId: voice}));
      final staff = Staff(id: const StaffId('s1'), measures: IMap({1: measure}));
      final part = Part(id: const PartId('p1'), name: 'Oboe', staves: IList([staff]));
      final score = Score(id: const ScoreId('score-12'), parts: IList([part]));

      final restored = ScoreIo.fromJsonString(ScoreIo.toJsonString(score));
      final rNote = restored.parts[0].staves[0].measures[1]!.voices[voiceId]!.events[0] as NoteEvent;
      expect(rNote.articulations.length, equals(2));
      expect(rNote.articulations[0].type, equals(ArticulationType.staccato));
      expect(rNote.articulations[0].placement, equals(Placement.above));
      expect(rNote.articulations[1].type, equals(ArticulationType.accent));
      expect(rNote.articulations[1].placement, isNull);
    });

    test('NoteEvent with lyrics roundtrips', () {
      final voiceId = const VoiceId('v1');
      final note = NoteEvent(
        id: const NoteId('n1'),
        offset: Fraction(0, 1),
        noteValue: const NoteValue(noteType: NoteType.quarter),
        pitch: const Pitch(step: Step.d, octave: 4),
        lyrics: IList([
          const Lyric(text: 'hel', syllabic: Syllabic.begin, number: 1),
          const Lyric(text: 'lo', syllabic: Syllabic.end, number: 1),
        ]),
      );
      final voice = Voice(id: voiceId, events: IList([note]));
      final measure = Measure(id: const MeasureId('m1'), voices: IMap({voiceId: voice}));
      final staff = Staff(id: const StaffId('s1'), measures: IMap({1: measure}));
      final part = Part(id: const PartId('p1'), name: 'Soprano', staves: IList([staff]));
      final score = Score(id: const ScoreId('score-13'), parts: IList([part]));

      final restored = ScoreIo.fromJsonString(ScoreIo.toJsonString(score));
      final rNote = restored.parts[0].staves[0].measures[1]!.voices[voiceId]!.events[0] as NoteEvent;
      expect(rNote.lyrics.length, equals(2));
      expect(rNote.lyrics[0].text, equals('hel'));
      expect(rNote.lyrics[0].syllabic, equals(Syllabic.begin));
      expect(rNote.lyrics[0].number, equals(1));
      expect(rNote.lyrics[1].text, equals('lo'));
      expect(rNote.lyrics[1].syllabic, equals(Syllabic.end));
    });
  });
}
