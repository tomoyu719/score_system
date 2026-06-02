import 'package:fast_immutable_collections/fast_immutable_collections.dart';
import 'package:score_core/score_core.dart';
import 'package:score_io/score_io.dart';
import 'package:test/test.dart';

Score _emptyScore() => Score(id: ScoreId('test-score'));

Score _scoreWithOnePart({Tempo? tempo}) {
  final partId = PartId('part-1');
  final staffId = StaffId('staff-1');
  final voiceId = VoiceId('voice-1');
  final ts = TimeSignature(beats: 4, beatType: 4);
  final ks = KeySignature(fifths: 0);
  final header = MeasureHeader(
    measureNumber: 1,
    timeSignature: ts,
    keySignature: ks,
    tempo: tempo,
  );
  final voice = Voice(id: voiceId);
  final measure = Measure(
    id: MeasureId('measure-1'),
    voices: IMap({voiceId: voice}),
  );
  final staff = Staff(id: staffId, measures: IMap({1: measure}));
  final part = Part(id: partId, name: 'Piano', staves: IList([staff]));
  return Score(
    id: ScoreId('test-score'),
    parts: IList([part]),
    measureHeaders: IList([header]),
  );
}

Score _scoreWithQuarterNoteC4() {
  final partId = PartId('part-1');
  final staffId = StaffId('staff-1');
  final voiceId = VoiceId('voice-1');
  final ts = TimeSignature(beats: 4, beatType: 4);
  final ks = KeySignature(fifths: 0);
  final header = MeasureHeader(
    measureNumber: 1,
    timeSignature: ts,
    keySignature: ks,
    tempo: Tempo(bpm: 120),
  );
  final note = NoteEvent(
    id: NoteId('note-1'),
    offset: Fraction(0, 1),
    noteValue: NoteValue(noteType: NoteType.quarter),
    pitch: Pitch(step: Step.c, octave: 4),
  );
  final voice = Voice(id: voiceId, events: IList([note]));
  final measure = Measure(id: MeasureId('measure-1'), voices: IMap({voiceId: voice}));
  final staff = Staff(id: staffId, measures: IMap({1: measure}));
  final part = Part(id: partId, name: 'Piano', staves: IList([staff]));
  return Score(
    id: ScoreId('test-score'),
    parts: IList([part]),
    measureHeaders: IList([header]),
  );
}

Score _scoreWithRestOnly() {
  final partId = PartId('part-1');
  final staffId = StaffId('staff-1');
  final voiceId = VoiceId('voice-1');
  final ts = TimeSignature(beats: 4, beatType: 4);
  final ks = KeySignature(fifths: 0);
  final header = MeasureHeader(
    measureNumber: 1,
    timeSignature: ts,
    keySignature: ks,
  );
  final rest = RestEvent(
    id: RestId('rest-1'),
    offset: Fraction(0, 1),
    noteValue: NoteValue(noteType: NoteType.quarter),
  );
  final voice = Voice(id: voiceId, events: IList([rest]));
  final measure = Measure(id: MeasureId('measure-1'), voices: IMap({voiceId: voice}));
  final staff = Staff(id: staffId, measures: IMap({1: measure}));
  final part = Part(id: partId, name: 'Piano', staves: IList([staff]));
  return Score(
    id: ScoreId('test-score'),
    parts: IList([part]),
    measureHeaders: IList([header]),
  );
}

Score _scoreWithChordC4E4() {
  final partId = PartId('part-1');
  final staffId = StaffId('staff-1');
  final voiceId = VoiceId('voice-1');
  final ts = TimeSignature(beats: 4, beatType: 4);
  final ks = KeySignature(fifths: 0);
  final header = MeasureHeader(
    measureNumber: 1,
    timeSignature: ts,
    keySignature: ks,
    tempo: Tempo(bpm: 120),
  );
  final noteC = NoteEvent(
    id: NoteId('note-c'),
    offset: Fraction(0, 1),
    noteValue: NoteValue(noteType: NoteType.quarter),
    pitch: Pitch(step: Step.c, octave: 4),
  );
  final noteE = NoteEvent(
    id: NoteId('note-e'),
    offset: Fraction(0, 1),
    noteValue: NoteValue(noteType: NoteType.quarter),
    pitch: Pitch(step: Step.e, octave: 4),
  );
  final chord = ChordEvent(
    id: ChordId('chord-1'),
    offset: Fraction(0, 1),
    noteValue: NoteValue(noteType: NoteType.quarter),
    notes: IList([noteC, noteE]),
  );
  final voice = Voice(id: voiceId, events: IList([chord]));
  final measure = Measure(id: MeasureId('measure-1'), voices: IMap({voiceId: voice}));
  final staff = Staff(id: staffId, measures: IMap({1: measure}));
  final part = Part(id: partId, name: 'Piano', staves: IList([staff]));
  return Score(
    id: ScoreId('test-score'),
    parts: IList([part]),
    measureHeaders: IList([header]),
  );
}

List<Map<String, Object?>> _trackEvents(
    Map<String, Object?> dump, int trackIndex) {
  final tracks = dump['tracks'] as List;
  final track = tracks[trackIndex] as Map<String, Object?>;
  return (track['events'] as List).cast<Map<String, Object?>>();
}

void main() {
  group('MidiJsonDump', () {
    test('empty score dump has ticksPerQuarterNote', () {
      final result = ScoreIo.dumpMidi(_emptyScore());
      expect(result['ticksPerQuarterNote'], equals(480));
    });

    test('empty score has tempo track only', () {
      final result = ScoreIo.dumpMidi(_emptyScore());
      final tracks = result['tracks'] as List;
      expect(tracks.length, equals(1));
      final track = tracks[0] as Map<String, Object?>;
      expect(track['trackIndex'], equals(0));
      expect(track['name'], equals('tempo'));
    });

    test('default tempo is 120 bpm', () {
      final result = ScoreIo.dumpMidi(_emptyScore());
      final events = _trackEvents(result, 0);
      final tempoEvent =
          events.firstWhere((e) => e['type'] == 'tempo');
      expect(tempoEvent['bpm'], equals(120.0));
      expect(tempoEvent['microsecondsPerQuarterNote'], equals(500000));
    });

    test('score with part creates track for part', () {
      final result = ScoreIo.dumpMidi(_scoreWithOnePart());
      final tracks = result['tracks'] as List;
      expect(tracks.length, equals(2));
      final partTrack = tracks[1] as Map<String, Object?>;
      expect(partTrack['trackIndex'], equals(1));
      expect(partTrack['name'], equals('Piano'));
    });

    test('note event appears as noteOn and noteOff with correct ticks', () {
      final result = ScoreIo.dumpMidi(_scoreWithQuarterNoteC4());
      final events = _trackEvents(result, 1);
      final noteOns = events.where((e) => e['type'] == 'noteOn').toList();
      final noteOffs = events.where((e) => e['type'] == 'noteOff').toList();
      expect(noteOns.length, equals(1));
      expect(noteOffs.length, equals(1));
    });

    test('noteOn tick matches offset (0 for first note)', () {
      final result = ScoreIo.dumpMidi(_scoreWithQuarterNoteC4());
      final events = _trackEvents(result, 1);
      final noteOn = events.firstWhere((e) => e['type'] == 'noteOn');
      expect(noteOn['tick'], equals(0));
    });

    test('noteOff tick = noteOn tick + duration ticks (480 for quarter)', () {
      final result = ScoreIo.dumpMidi(_scoreWithQuarterNoteC4());
      final events = _trackEvents(result, 1);
      final noteOn = events.firstWhere((e) => e['type'] == 'noteOn');
      final noteOff = events.firstWhere((e) => e['type'] == 'noteOff');
      expect(
        (noteOff['tick'] as int) - (noteOn['tick'] as int),
        equals(480),
      );
    });

    test('rest does not produce note events', () {
      final result = ScoreIo.dumpMidi(_scoreWithRestOnly());
      final events = _trackEvents(result, 1);
      final noteEvents =
          events.where((e) => e['type'] == 'noteOn' || e['type'] == 'noteOff');
      expect(noteEvents, isEmpty);
    });

    test('chord produces noteOn for each note', () {
      final result = ScoreIo.dumpMidi(_scoreWithChordC4E4());
      final events = _trackEvents(result, 1);
      final noteOns = events.where((e) => e['type'] == 'noteOn').toList();
      expect(noteOns.length, equals(2));
      final pitches = noteOns.map((e) => e['pitch'] as int).toSet();
      expect(pitches, containsAll([60, 64])); // C4=60, E4=64
    });

    test('tempo track ends with endOfTrack event', () {
      final result = ScoreIo.dumpMidi(_emptyScore());
      final events = _trackEvents(result, 0);
      expect(events.last['type'], equals('endOfTrack'));
    });

    test('part track ends with endOfTrack event', () {
      final result = ScoreIo.dumpMidi(_scoreWithQuarterNoteC4());
      final events = _trackEvents(result, 1);
      expect(events.last['type'], equals('endOfTrack'));
    });
  });
}
