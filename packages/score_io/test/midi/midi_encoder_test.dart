import 'dart:typed_data';

import 'package:fast_immutable_collections/fast_immutable_collections.dart';
import 'package:score_core/score_core.dart';
import 'package:score_io/score_io.dart';
import 'package:test/test.dart';

Score _emptyScore() => Score(id: ScoreId('test-score'));

Score _scoreWithOnePart({String name = 'Piano'}) {
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
  final voice = Voice(id: voiceId);
  final measure = Measure(
    id: MeasureId('measure-1'),
    voices: IMap({voiceId: voice}),
  );
  final staff = Staff(id: staffId, measures: IMap({1: measure}));
  final part = Part(id: partId, name: name, staves: IList([staff]));
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

Score _scoreWithWholeNoteC4() {
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
    noteValue: NoteValue(noteType: NoteType.whole),
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

/// Reads a big-endian uint16 from [bytes] at [offset].
int _readUint16(Uint8List bytes, int offset) =>
    (bytes[offset] << 8) | bytes[offset + 1];

/// Reads a big-endian uint32 from [bytes] at [offset].
int _readUint32(Uint8List bytes, int offset) =>
    (bytes[offset] << 24) |
    (bytes[offset + 1] << 16) |
    (bytes[offset + 2] << 8) |
    bytes[offset + 3];

/// Returns the byte offset of the start of each track chunk in [bytes].
List<int> _findTrackOffsets(Uint8List bytes) {
  final offsets = <int>[];
  var i = 14; // skip MThd header (8 + 6)
  while (i + 8 <= bytes.length) {
    if (bytes[i] == 0x4D &&
        bytes[i + 1] == 0x54 &&
        bytes[i + 2] == 0x72 &&
        bytes[i + 3] == 0x6B) {
      offsets.add(i);
      final length = _readUint32(bytes, i + 4);
      i += 8 + length;
    } else {
      break;
    }
  }
  return offsets;
}

/// Returns the data bytes of a track chunk (everything after the 8-byte header).
Uint8List _trackData(Uint8List bytes, int trackOffset) {
  final length = _readUint32(bytes, trackOffset + 4);
  return bytes.sublist(trackOffset + 8, trackOffset + 8 + length);
}

/// Decodes a VLQ value from [data] at [index], returning (value, bytesConsumed).
(int, int) _decodeVlq(List<int> data, int index) {
  var value = 0;
  var bytesRead = 0;
  while (true) {
    final b = data[index + bytesRead];
    bytesRead++;
    value = (value << 7) | (b & 0x7F);
    if (b & 0x80 == 0) break;
  }
  return (value, bytesRead);
}

void main() {
  group('MidiEncoder', () {
    test('empty score produces valid MIDI header', () {
      final bytes = ScoreIo.encodeMidi(_emptyScore());
      expect(bytes[0], equals(0x4D)); // 'M'
      expect(bytes[1], equals(0x54)); // 'T'
      expect(bytes[2], equals(0x68)); // 'h'
      expect(bytes[3], equals(0x64)); // 'd'
      expect(_readUint32(bytes, 4), equals(6)); // header length always 6
      expect(_readUint16(bytes, 8), equals(1)); // format Type 1
    });

    test('empty score has 1 track (tempo track only)', () {
      final bytes = ScoreIo.encodeMidi(_emptyScore());
      expect(_readUint16(bytes, 10), equals(1)); // num tracks
    });

    test('score with one part has 2 tracks', () {
      final bytes = ScoreIo.encodeMidi(_scoreWithOnePart());
      expect(_readUint16(bytes, 10), equals(2));
    });

    test('ticks per quarter note is 480', () {
      final bytes = ScoreIo.encodeMidi(_emptyScore());
      expect(_readUint16(bytes, 12), equals(480));
    });

    test('tempo track contains correct tempo event for 120 bpm', () {
      final bytes = ScoreIo.encodeMidi(_scoreWithOnePart());
      final trackOffsets = _findTrackOffsets(bytes);
      final data = _trackData(bytes, trackOffsets[0]);
      // Find 0xFF 0x51 0x03 sequence
      var found = false;
      for (var i = 0; i < data.length - 5; i++) {
        if (data[i] == 0xFF && data[i + 1] == 0x51 && data[i + 2] == 0x03) {
          final microseconds =
              (data[i + 3] << 16) | (data[i + 4] << 8) | data[i + 5];
          expect(microseconds, equals(500000)); // 60_000_000 / 120
          found = true;
          break;
        }
      }
      expect(found, isTrue, reason: 'tempo meta-event not found');
    });

    test('default tempo is 120 bpm when no measure headers', () {
      final bytes = ScoreIo.encodeMidi(_emptyScore());
      final trackOffsets = _findTrackOffsets(bytes);
      final data = _trackData(bytes, trackOffsets[0]);
      var found = false;
      for (var i = 0; i < data.length - 5; i++) {
        if (data[i] == 0xFF && data[i + 1] == 0x51 && data[i + 2] == 0x03) {
          final microseconds =
              (data[i + 3] << 16) | (data[i + 4] << 8) | data[i + 5];
          expect(microseconds, equals(500000));
          found = true;
          break;
        }
      }
      expect(found, isTrue);
    });

    test('all tracks end with end-of-track meta', () {
      final bytes = ScoreIo.encodeMidi(_scoreWithOnePart());
      final trackOffsets = _findTrackOffsets(bytes);
      for (final offset in trackOffsets) {
        final data = _trackData(bytes, offset);
        // last 3 bytes should be FF 2F 00
        expect(data[data.length - 3], equals(0xFF));
        expect(data[data.length - 2], equals(0x2F));
        expect(data[data.length - 1], equals(0x00));
      }
    });

    test('quarter note produces note on and note off 480 ticks apart', () {
      final bytes = ScoreIo.encodeMidi(_scoreWithQuarterNoteC4());
      final trackOffsets = _findTrackOffsets(bytes);
      // track 1 is the music track
      final data = _trackData(bytes, trackOffsets[1]);

      // Parse events to find note on and note off with accumulated ticks
      var cursor = 0;
      var absoluteTick = 0;
      int? noteOnTick;
      int? noteOffTick;

      while (cursor < data.length) {
        final (delta, consumed) = _decodeVlq(data, cursor);
        cursor += consumed;
        absoluteTick += delta;

        if (cursor >= data.length) break;
        final status = data[cursor];

        if (status == 0xFF) {
          // meta event
          cursor++;
          final metaType = data[cursor++];
          final (metaLen, lenBytes) = _decodeVlq(data, cursor);
          cursor += lenBytes + metaLen;
          if (metaType == 0x2F) break; // end of track
        } else if ((status & 0xF0) == 0x90) {
          // note on
          noteOnTick = absoluteTick;
          cursor += 3;
        } else if ((status & 0xF0) == 0x80) {
          // note off
          noteOffTick = absoluteTick;
          cursor += 3;
        } else {
          cursor++;
        }
      }

      expect(noteOnTick, isNotNull, reason: 'no noteOn found');
      expect(noteOffTick, isNotNull, reason: 'no noteOff found');
      expect(noteOffTick! - noteOnTick!, equals(480));
    });

    test('note MIDI pitch is correct — C4 = 60', () {
      final bytes = ScoreIo.encodeMidi(_scoreWithQuarterNoteC4());
      final trackOffsets = _findTrackOffsets(bytes);
      final data = _trackData(bytes, trackOffsets[1]);

      var cursor = 0;
      bool foundC4 = false;

      while (cursor < data.length - 2) {
        final (_, consumed) = _decodeVlq(data, cursor);
        cursor += consumed;
        if (cursor >= data.length) break;
        final status = data[cursor];
        if (status == 0xFF) {
          cursor++;
          cursor++; // meta type
          final (metaLen, lenBytes) = _decodeVlq(data, cursor);
          cursor += lenBytes + metaLen;
        } else if ((status & 0xF0) == 0x90) {
          cursor++;
          final pitch = data[cursor];
          if (pitch == 60) foundC4 = true;
          cursor += 2;
        } else if ((status & 0xF0) == 0x80) {
          cursor += 3;
        } else {
          cursor++;
        }
      }

      expect(foundC4, isTrue, reason: 'C4 (MIDI 60) not found in note-on');
    });

    test('rest produces no note events', () {
      final bytes = ScoreIo.encodeMidi(_scoreWithRestOnly());
      final trackOffsets = _findTrackOffsets(bytes);
      final data = _trackData(bytes, trackOffsets[1]);

      var cursor = 0;
      var noteEventCount = 0;

      while (cursor < data.length) {
        final (_, consumed) = _decodeVlq(data, cursor);
        cursor += consumed;
        if (cursor >= data.length) break;
        final status = data[cursor];
        if (status == 0xFF) {
          cursor++;
          cursor++; // meta type
          final (metaLen, lenBytes) = _decodeVlq(data, cursor);
          cursor += lenBytes + metaLen;
        } else if ((status & 0xF0) == 0x90 || (status & 0xF0) == 0x80) {
          noteEventCount++;
          cursor += 3;
        } else {
          cursor++;
        }
      }

      expect(noteEventCount, equals(0));
    });

    test('whole note produces note off at 1920 ticks from start', () {
      final bytes = ScoreIo.encodeMidi(_scoreWithWholeNoteC4());
      final trackOffsets = _findTrackOffsets(bytes);
      final data = _trackData(bytes, trackOffsets[1]);

      var cursor = 0;
      var absoluteTick = 0;
      int? noteOffTick;

      while (cursor < data.length) {
        final (delta, consumed) = _decodeVlq(data, cursor);
        cursor += consumed;
        absoluteTick += delta;
        if (cursor >= data.length) break;
        final status = data[cursor];
        if (status == 0xFF) {
          cursor++;
          final metaType = data[cursor++];
          final (metaLen, lenBytes) = _decodeVlq(data, cursor);
          cursor += lenBytes + metaLen;
          if (metaType == 0x2F) break;
        } else if ((status & 0xF0) == 0x80) {
          noteOffTick = absoluteTick;
          cursor += 3;
        } else if ((status & 0xF0) == 0x90) {
          cursor += 3;
        } else {
          cursor++;
        }
      }

      expect(noteOffTick, equals(1920));
    });
  });
}
