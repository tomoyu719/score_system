part of 'music_event.dart';

/// A percussion hit event: an unpitched note mapped to a specific drum instrument.
final class PercussionNote extends MusicEvent {
  const PercussionNote({
    required this.id,
    required super.offset,
    required super.noteValue,
    required this.instrument,
    this.articulations = const IListConst([]),
    this.isGrace = false,
  });

  final PercussionNoteId id;

  /// The drum instrument being struck.
  final DrumInstrument instrument;

  final IList<Articulation> articulations;
  final bool isGrace;

  PercussionNote copyWith({
    PercussionNoteId? id,
    Fraction? offset,
    NoteValue? noteValue,
    DrumInstrument? instrument,
    IList<Articulation>? articulations,
    bool? isGrace,
  }) =>
      PercussionNote(
        id: id ?? this.id,
        offset: offset ?? this.offset,
        noteValue: noteValue ?? this.noteValue,
        instrument: instrument ?? this.instrument,
        articulations: articulations ?? this.articulations,
        isGrace: isGrace ?? this.isGrace,
      );

  @override
  bool operator ==(Object other) {
    if (other is! PercussionNote) return false;
    return id == other.id &&
        offset == other.offset &&
        noteValue == other.noteValue &&
        instrument == other.instrument &&
        articulations == other.articulations &&
        isGrace == other.isGrace;
  }

  @override
  int get hashCode =>
      Object.hash(id, offset, noteValue, instrument, articulations, isGrace);
}
