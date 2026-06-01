part of 'music_event.dart';

/// A single note event.
final class NoteEvent extends MusicEvent {
  const NoteEvent({
    required this.id,
    required super.offset,
    required super.noteValue,
    required this.pitch,
    this.articulations = const IListConst([]),
    this.dynamics = const IListConst([]),
    this.lyrics = const IListConst([]),
    this.fingering,
    this.isGrace = false,
  });

  final NoteId id;
  final Pitch pitch;
  final IList<Articulation> articulations;
  final IList<Dynamic> dynamics;
  final IList<Lyric> lyrics;
  final Fingering? fingering;
  final bool isGrace;

  NoteEvent copyWith({
    NoteId? id,
    Fraction? offset,
    NoteValue? noteValue,
    Pitch? pitch,
    IList<Articulation>? articulations,
    IList<Dynamic>? dynamics,
    IList<Lyric>? lyrics,
    Fingering? fingering,
    bool? isGrace,
  }) =>
      NoteEvent(
        id: id ?? this.id,
        offset: offset ?? this.offset,
        noteValue: noteValue ?? this.noteValue,
        pitch: pitch ?? this.pitch,
        articulations: articulations ?? this.articulations,
        dynamics: dynamics ?? this.dynamics,
        lyrics: lyrics ?? this.lyrics,
        fingering: fingering ?? this.fingering,
        isGrace: isGrace ?? this.isGrace,
      );
}
