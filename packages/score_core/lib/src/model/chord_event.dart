part of 'music_event.dart';

/// A chord: multiple simultaneous notes sharing offset and duration.
final class ChordEvent extends MusicEvent {
  const ChordEvent({
    required this.id,
    required super.offset,
    required super.noteValue,
    required this.notes,
    this.articulations = const IListConst([]),
    this.dynamics = const IListConst([]),
  });

  final ChordId id;

  /// All notes in the chord. Must share the same offset as this ChordEvent.
  final IList<NoteEvent> notes;
  final IList<Articulation> articulations;
  final IList<Dynamic> dynamics;

  ChordEvent copyWith({
    ChordId? id,
    Fraction? offset,
    NoteValue? noteValue,
    IList<NoteEvent>? notes,
    IList<Articulation>? articulations,
    IList<Dynamic>? dynamics,
  }) =>
      ChordEvent(
        id: id ?? this.id,
        offset: offset ?? this.offset,
        noteValue: noteValue ?? this.noteValue,
        notes: notes ?? this.notes,
        articulations: articulations ?? this.articulations,
        dynamics: dynamics ?? this.dynamics,
      );
}
