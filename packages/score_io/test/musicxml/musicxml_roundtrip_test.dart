import 'package:fast_immutable_collections/fast_immutable_collections.dart';
import 'package:score_core/score_core.dart';
import 'package:score_io/score_io.dart';
import 'package:test/test.dart';

Score _buildScore({
  String title = '',
  String composer = '',
  List<MeasureHeader> headers = const [],
  List<Part> parts = const [],
}) =>
    Score(
      id: const ScoreId('s1'),
      title: title,
      composer: composer,
      measureHeaders: IList(headers),
      parts: IList(parts),
    );

Part _simplePart(List<MusicEvent> events) => Part(
      id: const PartId('P1'),
      name: 'Piano',
      staves: IList([
        Staff(
          id: const StaffId('S1'),
          measures: IMap({
            1: Measure(
              id: const MeasureId('m1'),
              voices: IMap({
                const VoiceId('1'): Voice(
                  id: const VoiceId('1'),
                  events: IList(events),
                ),
              }),
            ),
          }),
        ),
      ]),
    );

MeasureHeader _defaultHeader({int measureNumber = 1, Tempo? tempo}) =>
    MeasureHeader(
      measureNumber: measureNumber,
      timeSignature: const TimeSignature(beats: 4, beatType: 4),
      keySignature: const KeySignature(fifths: 0),
      tempo: tempo,
    );

void main() {
  final exporter = MusicXmlExporter();
  final parser = MusicXmlParser();

  Score roundtrip(Score score) => parser.parse(exporter.export(score));

  group('MusicXML roundtrip', () {
    test('note roundtrip: parse → export → parse produces same pitch/noteValue', () {
      const pitch = Pitch(step: Step.f, alter: 1.0, octave: 5);
      final note = NoteEvent(
        id: const NoteId('n1'),
        offset: Fraction.zero,
        noteValue: const NoteValue(noteType: NoteType.eighth),
        pitch: pitch,
      );
      final score = _buildScore(
        headers: [_defaultHeader()],
        parts: [_simplePart([note])],
      );

      final restored = roundtrip(score);

      final voice = restored.parts[0].staves[0].measures[1]!.voices[const VoiceId('1')]!;
      final restoredNote = voice.events[0] as NoteEvent;
      expect(restoredNote.pitch.step, equals(Step.f));
      expect(restoredNote.pitch.alter, equals(1.0));
      expect(restoredNote.pitch.octave, equals(5));
      expect(restoredNote.noteValue.noteType, equals(NoteType.eighth));
    });

    test('rest roundtrip', () {
      final rest = RestEvent(
        id: const RestId('r1'),
        offset: Fraction.zero,
        noteValue: const NoteValue(noteType: NoteType.whole),
      );
      final score = _buildScore(
        headers: [_defaultHeader()],
        parts: [_simplePart([rest])],
      );

      final restored = roundtrip(score);

      final voice = restored.parts[0].staves[0].measures[1]!.voices[const VoiceId('1')]!;
      expect(voice.events[0], isA<RestEvent>());
      expect((voice.events[0] as RestEvent).noteValue.noteType, equals(NoteType.whole));
    });

    test('multi-measure roundtrip preserves measure count', () {
      Part buildPart() {
        final staffId = const StaffId('S1');
        final voiceId = const VoiceId('1');
        return Part(
          id: const PartId('P1'),
          name: 'Piano',
          staves: IList([
            Staff(
              id: staffId,
              measures: IMap({
                1: Measure(
                  id: const MeasureId('m1'),
                  voices: IMap({
                    voiceId: Voice(
                      id: voiceId,
                      events: IList([
                        NoteEvent(
                          id: const NoteId('n1'),
                          offset: Fraction.zero,
                          noteValue: const NoteValue(noteType: NoteType.whole),
                          pitch: const Pitch(step: Step.c, octave: 4),
                        ),
                      ]),
                    ),
                  }),
                ),
                2: Measure(
                  id: const MeasureId('m2'),
                  voices: IMap({
                    voiceId: Voice(
                      id: voiceId,
                      events: IList([
                        NoteEvent(
                          id: const NoteId('n2'),
                          offset: Fraction.zero,
                          noteValue: const NoteValue(noteType: NoteType.whole),
                          pitch: const Pitch(step: Step.d, octave: 4),
                        ),
                      ]),
                    ),
                  }),
                ),
              }),
            ),
          ]),
        );
      }

      final score = _buildScore(
        headers: [
          _defaultHeader(measureNumber: 1),
          _defaultHeader(measureNumber: 2),
        ],
        parts: [buildPart()],
      );

      final restored = roundtrip(score);

      expect(restored.parts[0].staves[0].measures.length, equals(2));
    });

    test('title and composer roundtrip', () {
      final score = _buildScore(
        title: 'Nocturne',
        composer: 'Chopin',
        headers: [_defaultHeader()],
      );

      final restored = roundtrip(score);

      expect(restored.title, equals('Nocturne'));
      expect(restored.composer, equals('Chopin'));
    });

    test('time signature roundtrip', () {
      final score = _buildScore(
        headers: [
          MeasureHeader(
            measureNumber: 1,
            timeSignature: const TimeSignature(beats: 6, beatType: 8),
            keySignature: const KeySignature(fifths: 0),
          ),
        ],
        parts: [
          Part(
            id: const PartId('P1'),
            name: 'Piano',
            staves: IList([
              Staff(
                id: const StaffId('S1'),
                measures: IMap({1: Measure(id: const MeasureId('m1'))}),
              ),
            ]),
          ),
        ],
      );

      final restored = roundtrip(score);

      expect(restored.measureHeaders[0].timeSignature.beats, equals(6));
      expect(restored.measureHeaders[0].timeSignature.beatType, equals(8));
    });

    test('key signature roundtrip', () {
      final score = _buildScore(
        headers: [
          MeasureHeader(
            measureNumber: 1,
            timeSignature: const TimeSignature(beats: 4, beatType: 4),
            keySignature: const KeySignature(fifths: -3, mode: Mode.minor),
          ),
        ],
        parts: [
          Part(
            id: const PartId('P1'),
            name: 'Piano',
            staves: IList([
              Staff(
                id: const StaffId('S1'),
                measures: IMap({1: Measure(id: const MeasureId('m1'))}),
              ),
            ]),
          ),
        ],
      );

      final restored = roundtrip(score);

      expect(restored.measureHeaders[0].keySignature.fifths, equals(-3));
      expect(restored.measureHeaders[0].keySignature.mode, equals(Mode.minor));
    });
  });
}
