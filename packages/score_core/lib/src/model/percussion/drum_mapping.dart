import 'package:fast_immutable_collections/fast_immutable_collections.dart';

import 'drum_instrument.dart';
import 'note_head_type.dart';

/// Maps MIDI note numbers to [DrumInstrument] entries.
final class DrumMapping {
  const DrumMapping({required this.midiNoteToInstrument});

  /// Instrument lookup keyed by MIDI note number.
  final IMap<int, DrumInstrument> midiNoteToInstrument;

  /// Returns the [DrumInstrument] for [midiNote], or null if not mapped.
  DrumInstrument? lookup(int midiNote) => midiNoteToInstrument[midiNote];

  @override
  bool operator ==(Object other) {
    if (other is! DrumMapping) return false;
    return midiNoteToInstrument == other.midiNoteToInstrument;
  }

  @override
  int get hashCode => midiNoteToInstrument.hashCode;
}

/// Standard General MIDI drum map (common entries).
final generalMidiDrumMap = DrumMapping(
  midiNoteToInstrument: IMap({
    35: const DrumInstrument(
      name: 'Bass Drum 2',
      staffLine: -4,
      noteHeadType: NoteHeadType.normal,
      midiNote: 35,
    ),
    36: const DrumInstrument(
      name: 'Bass Drum 1',
      staffLine: -4,
      noteHeadType: NoteHeadType.normal,
      midiNote: 36,
    ),
    38: const DrumInstrument(
      name: 'Snare',
      staffLine: 0,
      noteHeadType: NoteHeadType.normal,
      midiNote: 38,
    ),
    42: const DrumInstrument(
      name: 'Hi-Hat Closed',
      staffLine: 4,
      noteHeadType: NoteHeadType.cross,
      midiNote: 42,
    ),
    44: const DrumInstrument(
      name: 'Hi-Hat Pedal',
      staffLine: -5,
      noteHeadType: NoteHeadType.cross,
      midiNote: 44,
    ),
    46: const DrumInstrument(
      name: 'Hi-Hat Open',
      staffLine: 4,
      noteHeadType: NoteHeadType.openCross,
      midiNote: 46,
    ),
    49: const DrumInstrument(
      name: 'Crash Cymbal 1',
      staffLine: 5,
      noteHeadType: NoteHeadType.cross,
      midiNote: 49,
    ),
    51: const DrumInstrument(
      name: 'Ride Cymbal 1',
      staffLine: 5,
      noteHeadType: NoteHeadType.cross,
      midiNote: 51,
    ),
  }),
);
