import 'dart:typed_data';

import 'package:score_core/score_core.dart';

/// Encodes a [Score] into a Standard MIDI File (SMF) Type 1 binary.
///
/// Format: 1 tempo track (track 0) + 1 track per Part.
/// Ticks per quarter note defaults to 480.
final class MidiEncoder {
  const MidiEncoder({this.ticksPerQuarterNote = 480});

  final int ticksPerQuarterNote;

  static const int _wholeTicks = 4; // whole note = 4 quarter notes

  int get _wholeNoteTicks => ticksPerQuarterNote * _wholeTicks;

  /// Encodes [score] to SMF Type 1 bytes.
  Uint8List encode(Score score) {
    final tempoTrack = _buildTempoTrack(score);
    final partTracks = <List<int>>[];
    for (final part in score.parts) {
      partTracks.add(_buildPartTrack(score, part));
    }

    final trackCount = 1 + partTracks.length;
    final output = BytesBuilder();
    output.add(_mthd(trackCount));
    output.add(tempoTrack);
    for (final t in partTracks) {
      output.add(t);
    }
    return output.toBytes();
  }

  List<int> _mthd(int trackCount) {
    return [
      // "MThd"
      0x4D, 0x54, 0x68, 0x64,
      // length = 6
      0x00, 0x00, 0x00, 0x06,
      // format = 1
      0x00, 0x01,
      // number of tracks
      (trackCount >> 8) & 0xFF, trackCount & 0xFF,
      // ticks per quarter note
      (ticksPerQuarterNote >> 8) & 0xFF, ticksPerQuarterNote & 0xFF,
    ];
  }

  List<int> _buildTempoTrack(Score score) {
    final events = <int>[];

    final bpm = _firstBpm(score);
    final uspq = (60000000 / bpm).round();
    events.addAll([
      0x00, // delta = 0
      0xFF, 0x51, 0x03,
      (uspq >> 16) & 0xFF,
      (uspq >> 8) & 0xFF,
      uspq & 0xFF,
    ]);

    events.addAll([0x00, 0xFF, 0x2F, 0x00]);

    return _mtrk(events);
  }

  List<int> _buildPartTrack(Score score, Part part) {
    final rawEvents = <_MidiRawEvent>[];

    var voiceIndex = 0;
    for (final staff in part.staves) {
      for (final measureEntry in staff.measures.entries) {
        final measureNumber = measureEntry.key;
        final measure = measureEntry.value;
        final measureStartTick = _measureStartTick(score, measureNumber);

        for (final voiceEntry in measure.voices.entries) {
          final channel = voiceIndex % 16;
          final voice = voiceEntry.value;
          for (final event in voice.events) {
            final offsetTicks =
                _fractionToTicks(event.offset);
            final durationTicks =
                _fractionToTicks(event.noteValue.toFraction());
            final onTick = measureStartTick + offsetTicks;
            final offTick = onTick + durationTicks;

            switch (event) {
              case NoteEvent():
                rawEvents.add(_MidiRawEvent(
                  tick: onTick,
                  isNoteOn: true,
                  channel: channel,
                  pitch: event.pitch.midiPitch,
                ));
                rawEvents.add(_MidiRawEvent(
                  tick: offTick,
                  isNoteOn: false,
                  channel: channel,
                  pitch: event.pitch.midiPitch,
                ));
              case ChordEvent():
                for (final note in event.notes) {
                  rawEvents.add(_MidiRawEvent(
                    tick: onTick,
                    isNoteOn: true,
                    channel: channel,
                    pitch: note.pitch.midiPitch,
                  ));
                  rawEvents.add(_MidiRawEvent(
                    tick: offTick,
                    isNoteOn: false,
                    channel: channel,
                    pitch: note.pitch.midiPitch,
                  ));
                }
              case RestEvent():
                break;
              case PercussionNote():
                rawEvents.add(_MidiRawEvent(
                  tick: onTick,
                  isNoteOn: true,
                  channel: channel,
                  pitch: event.instrument.midiNote,
                ));
                rawEvents.add(_MidiRawEvent(
                  tick: offTick,
                  isNoteOn: false,
                  channel: channel,
                  pitch: event.instrument.midiNote,
                ));
            }
          }
          voiceIndex++;
        }
      }
    }

    // Sort: by tick, then note-off before note-on at the same tick.
    rawEvents.sort((a, b) {
      final tickCmp = a.tick.compareTo(b.tick);
      if (tickCmp != 0) return tickCmp;
      // note-off (isNoteOn=false) sorts before note-on
      if (!a.isNoteOn && b.isNoteOn) return -1;
      if (a.isNoteOn && !b.isNoteOn) return 1;
      return 0;
    });

    final bytes = <int>[];
    var prevTick = 0;
    for (final e in rawEvents) {
      final delta = e.tick - prevTick;
      prevTick = e.tick;
      bytes.addAll(_encodeVlq(delta));
      if (e.isNoteOn) {
        bytes.addAll([0x90 | e.channel, e.pitch, 64]);
      } else {
        bytes.addAll([0x80 | e.channel, e.pitch, 0]);
      }
    }

    // End of Track
    bytes.addAll([0x00, 0xFF, 0x2F, 0x00]);

    return _mtrk(bytes);
  }

  List<int> _mtrk(List<int> data) {
    final len = data.length;
    return [
      0x4D, 0x54, 0x72, 0x6B, // "MTrk"
      (len >> 24) & 0xFF,
      (len >> 16) & 0xFF,
      (len >> 8) & 0xFF,
      len & 0xFF,
      ...data,
    ];
  }

  int _measureStartTick(Score score, int measureNumber) {
    var tick = 0;
    for (var m = 1; m < measureNumber; m++) {
      final header = score.headerForMeasure(m);
      if (header != null) {
        tick += _fractionToTicks(header.measureDuration);
      }
    }
    return tick;
  }

  int _fractionToTicks(Fraction f) =>
      (f.numerator * _wholeNoteTicks) ~/ f.denominator;

  double _firstBpm(Score score) {
    for (final header in score.measureHeaders) {
      final tempo = header.tempo;
      if (tempo != null) return tempo.bpm;
    }
    return 120.0;
  }
}

final class _MidiRawEvent {
  const _MidiRawEvent({
    required this.tick,
    required this.isNoteOn,
    required this.channel,
    required this.pitch,
  });

  final int tick;
  final bool isNoteOn;
  final int channel;
  final int pitch;
}

List<int> _encodeVlq(int value) {
  if (value < 0x80) return [value];
  final bytes = <int>[];
  bytes.add(value & 0x7F);
  value >>= 7;
  while (value > 0) {
    bytes.add((value & 0x7F) | 0x80);
    value >>= 7;
  }
  return bytes.reversed.toList();
}
