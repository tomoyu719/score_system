import 'package:fast_immutable_collections/fast_immutable_collections.dart';
import 'package:score_core/score_core.dart';
import 'package:score_io/score_io.dart';
import 'package:test/test.dart';
import 'package:xml/xml.dart';

Score _scoreWith({
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

MeasureHeader _header({
  int measureNumber = 1,
  int beats = 4,
  int beatType = 4,
  int fifths = 0,
  Mode mode = Mode.major,
  Tempo? tempo,
  BarlineType barlineEnd = BarlineType.regular,
}) =>
    MeasureHeader(
      measureNumber: measureNumber,
      timeSignature: TimeSignature(beats: beats, beatType: beatType),
      keySignature: KeySignature(fifths: fifths, mode: mode),
      tempo: tempo,
      barlineEnd: barlineEnd,
    );

Part _partWithNote({
  String partId = 'P1',
  String partName = 'Piano',
  NoteEvent? note,
  RestEvent? rest,
}) {
  final staffId = const StaffId('S1');
  final voiceId = const VoiceId('1');
  final events = <MusicEvent>[];
  if (note != null) events.add(note);
  if (rest != null) events.add(rest);
  return Part(
    id: PartId(partId),
    name: partName,
    staves: IList([
      Staff(
        id: staffId,
        measures: IMap({
          1: Measure(
            id: const MeasureId('m1'),
            voices: IMap({voiceId: Voice(id: voiceId, events: IList(events))}),
          ),
        }),
      ),
    ]),
  );
}

void main() {
  final exporter = MusicXmlExporter();

  group('MusicXmlExporter', () {
    test('exports empty score with title', () {
      final score = _scoreWith(
        title: 'Test Title',
        composer: 'Test Composer',
        headers: [_header()],
      );
      final xml = exporter.export(score);

      expect(xml, contains('<movement-title>Test Title</movement-title>'));
      expect(xml, contains('Test Composer'));
      expect(xml, contains('score-partwise'));
    });

    test('exported XML contains valid UTF-8 declaration', () {
      final score = _scoreWith(headers: [_header()]);
      final xml = exporter.export(score);

      expect(xml, startsWith('<?xml'));
      expect(xml.toLowerCase(), contains('encoding="utf-8"'));
    });

    test('exports time and key signatures', () {
      final score = _scoreWith(
        headers: [_header(beats: 3, beatType: 4, fifths: 2, mode: Mode.major)],
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
      final xml = exporter.export(score);

      expect(xml, contains('<beats>3</beats>'));
      expect(xml, contains('<beat-type>4</beat-type>'));
      expect(xml, contains('<fifths>2</fifths>'));
      expect(xml, contains('<mode>major</mode>'));
    });

    test('exports quarter note with correct duration ticks', () {
      final note = NoteEvent(
        id: const NoteId('n1'),
        offset: Fraction.zero,
        noteValue: const NoteValue(noteType: NoteType.quarter),
        pitch: const Pitch(step: Step.c, octave: 4),
      );
      final score = _scoreWith(
        headers: [_header()],
        parts: [_partWithNote(note: note)],
      );
      final xml = exporter.export(score);
      final doc = XmlDocument.parse(xml);

      final durationEl = doc.findAllElements('duration').first;
      expect(durationEl.innerText, equals('4'));
      final typeEl = doc.findAllElements('type').first;
      expect(typeEl.innerText, equals('quarter'));
      final stepEl = doc.findAllElements('step').first;
      expect(stepEl.innerText, equals('C'));
      final octaveEl = doc.findAllElements('octave').first;
      expect(octaveEl.innerText, equals('4'));
    });

    test('exports rest', () {
      final rest = RestEvent(
        id: const RestId('r1'),
        offset: Fraction.zero,
        noteValue: const NoteValue(noteType: NoteType.half),
      );
      final score = _scoreWith(
        headers: [_header()],
        parts: [_partWithNote(rest: rest)],
      );
      final xml = exporter.export(score);
      final doc = XmlDocument.parse(xml);

      expect(doc.findAllElements('rest'), isNotEmpty);
      final typeEl = doc.findAllElements('type').first;
      expect(typeEl.innerText, equals('half'));
      final durationEl = doc.findAllElements('duration').first;
      expect(durationEl.innerText, equals('8'));
    });

    test('exports dotted note', () {
      final note = NoteEvent(
        id: const NoteId('n1'),
        offset: Fraction.zero,
        noteValue: const NoteValue(noteType: NoteType.quarter, dots: 1),
        pitch: const Pitch(step: Step.g, octave: 4),
      );
      final score = _scoreWith(
        headers: [_header()],
        parts: [_partWithNote(note: note)],
      );
      final xml = exporter.export(score);
      final doc = XmlDocument.parse(xml);

      expect(doc.findAllElements('dot'), isNotEmpty);
      final durationEl = doc.findAllElements('duration').first;
      expect(durationEl.innerText, equals('6'));
    });

    test('exports final barline', () {
      final score = _scoreWith(
        headers: [_header(barlineEnd: BarlineType.finalBar)],
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
      final xml = exporter.export(score);

      expect(xml, contains('light-heavy'));
    });

    test('exports tempo', () {
      final score = _scoreWith(
        headers: [
          _header(tempo: const Tempo(bpm: 96, beatUnit: NoteType.quarter)),
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
      final xml = exporter.export(score);

      expect(xml, contains('<beat-unit>quarter</beat-unit>'));
      expect(xml, contains('<per-minute>96'));
    });
  });
}
