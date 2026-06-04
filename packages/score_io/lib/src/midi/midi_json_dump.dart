import 'package:score_core/score_core.dart';

/// Converts a [Score] to a JSON-serializable Map describing MIDI events.
///
/// Useful for debugging/inspection without binary MIDI parsing.
final class MidiJsonDump {
  const MidiJsonDump({this.ticksPerQuarterNote = 480});

  final int ticksPerQuarterNote;

  int get _wholeNoteTicks => ticksPerQuarterNote * 4;

  /// Returns a JSON-serializable map describing all MIDI tracks and events.
  Map<String, Object?> dump(Score score) {
    final tracks = <Map<String, Object?>>[];
    tracks.add(_buildTempoTrack(score));
    for (var i = 0; i < score.parts.length; i++) {
      tracks.add(_buildPartTrack(score, score.parts[i], i + 1));
    }
    return {
      'ticksPerQuarterNote': ticksPerQuarterNote,
      'tracks': tracks,
    };
  }

  Map<String, Object?> _buildTempoTrack(Score score) {
    final bpm = _firstBpm(score);
    final uspq = (60000000 / bpm).round();
    return {
      'trackIndex': 0,
      'name': 'tempo',
      'events': [
        {
          'tick': 0,
          'type': 'tempo',
          'bpm': bpm,
          'microsecondsPerQuarterNote': uspq,
        },
        {'tick': 0, 'type': 'endOfTrack'},
      ],
    };
  }

  Map<String, Object?> _buildPartTrack(
      Score score, Part part, int trackIndex) {
    final rawEvents = <_JsonEvent>[];

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
            final onTick =
                measureStartTick + _fractionToTicks(event.offset);
            final offTick =
                onTick + _fractionToTicks(event.noteValue.toFraction());

            switch (event) {
              case NoteEvent():
                rawEvents.add(_JsonEvent(
                  tick: onTick,
                  isNoteOn: true,
                  channel: channel,
                  pitch: event.pitch.midiPitch,
                ));
                rawEvents.add(_JsonEvent(
                  tick: offTick,
                  isNoteOn: false,
                  channel: channel,
                  pitch: event.pitch.midiPitch,
                ));
              case ChordEvent():
                for (final note in event.notes) {
                  rawEvents.add(_JsonEvent(
                    tick: onTick,
                    isNoteOn: true,
                    channel: channel,
                    pitch: note.pitch.midiPitch,
                  ));
                  rawEvents.add(_JsonEvent(
                    tick: offTick,
                    isNoteOn: false,
                    channel: channel,
                    pitch: note.pitch.midiPitch,
                  ));
                }
              case RestEvent():
                break;
              case PercussionNote():
                rawEvents.add(_JsonEvent(
                  tick: onTick,
                  isNoteOn: true,
                  channel: channel,
                  pitch: event.instrument.midiNote,
                ));
                rawEvents.add(_JsonEvent(
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

    rawEvents.sort((a, b) {
      final tickCmp = a.tick.compareTo(b.tick);
      if (tickCmp != 0) return tickCmp;
      if (!a.isNoteOn && b.isNoteOn) return -1;
      if (a.isNoteOn && !b.isNoteOn) return 1;
      return 0;
    });

    final endTick = rawEvents.isEmpty ? 0 : rawEvents.last.tick;

    final events = <Map<String, Object?>>[];
    for (final e in rawEvents) {
      events.add({
        'tick': e.tick,
        'type': e.isNoteOn ? 'noteOn' : 'noteOff',
        'channel': e.channel,
        'pitch': e.pitch,
        'velocity': e.isNoteOn ? 64 : 0,
      });
    }
    events.add({'tick': endTick, 'type': 'endOfTrack'});

    return {
      'trackIndex': trackIndex,
      'name': part.name,
      'events': events,
    };
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

final class _JsonEvent {
  const _JsonEvent({
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
