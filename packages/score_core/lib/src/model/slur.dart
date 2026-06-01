import '../ids.dart';
import 'placement.dart';

/// A slur connecting two notes.
final class Slur {
  const Slur({
    required this.id,
    required this.startNoteId,
    required this.endNoteId,
    this.placement,
  });

  final SlurId id;
  final NoteId startNoteId;
  final NoteId endNoteId;
  final Placement? placement;

  Slur copyWith({
    SlurId? id,
    NoteId? startNoteId,
    NoteId? endNoteId,
    Placement? placement,
  }) =>
      Slur(
        id: id ?? this.id,
        startNoteId: startNoteId ?? this.startNoteId,
        endNoteId: endNoteId ?? this.endNoteId,
        placement: placement ?? this.placement,
      );
}
