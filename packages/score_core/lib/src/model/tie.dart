import '../ids.dart';

/// A tie connecting two notes of the same pitch across a barline or within a measure.
final class Tie {
  const Tie({
    required this.id,
    required this.startNoteId,
    required this.endNoteId,
  });

  final TieId id;
  final NoteId startNoteId;
  final NoteId endNoteId;

  Tie copyWith({
    TieId? id,
    NoteId? startNoteId,
    NoteId? endNoteId,
  }) =>
      Tie(
        id: id ?? this.id,
        startNoteId: startNoteId ?? this.startNoteId,
        endNoteId: endNoteId ?? this.endNoteId,
      );
}
