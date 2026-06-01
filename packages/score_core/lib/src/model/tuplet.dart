import 'package:fast_immutable_collections/fast_immutable_collections.dart';

import '../ids.dart';
import 'fraction.dart';

/// A tuplet group defining the rhythmic ratio for a set of notes.
final class Tuplet {
  const Tuplet({
    required this.id,
    required this.noteIds,
    required this.ratio,
  });

  final TupletId id;
  final IList<NoteId> noteIds;

  /// Ratio applied to each note's base duration (e.g., Fraction(2, 3) for triplet).
  final Fraction ratio;

  Tuplet copyWith({
    TupletId? id,
    IList<NoteId>? noteIds,
    Fraction? ratio,
  }) =>
      Tuplet(
        id: id ?? this.id,
        noteIds: noteIds ?? this.noteIds,
        ratio: ratio ?? this.ratio,
      );
}
