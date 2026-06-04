import 'note_head_type.dart';

/// A single drum/percussion instrument in a drum kit mapping.
final class DrumInstrument {
  const DrumInstrument({
    required this.name,
    required this.staffLine,
    required this.noteHeadType,
    required this.midiNote,
  });

  /// Display name (e.g. "Snare", "Hi-Hat Closed").
  final String name;

  /// Staff-line position: 0 = centre line, positive = above, negative = below.
  final int staffLine;

  /// Notehead shape for this instrument.
  final NoteHeadType noteHeadType;

  /// General MIDI drum note number (35–81).
  final int midiNote;

  DrumInstrument copyWith({
    String? name,
    int? staffLine,
    NoteHeadType? noteHeadType,
    int? midiNote,
  }) =>
      DrumInstrument(
        name: name ?? this.name,
        staffLine: staffLine ?? this.staffLine,
        noteHeadType: noteHeadType ?? this.noteHeadType,
        midiNote: midiNote ?? this.midiNote,
      );

  @override
  bool operator ==(Object other) {
    if (other is! DrumInstrument) return false;
    return name == other.name &&
        staffLine == other.staffLine &&
        noteHeadType == other.noteHeadType &&
        midiNote == other.midiNote;
  }

  @override
  int get hashCode => Object.hash(name, staffLine, noteHeadType, midiNote);
}
