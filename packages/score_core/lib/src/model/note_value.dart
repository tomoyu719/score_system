import 'fraction.dart';
import 'note_type.dart';

/// Musical duration value. Called "Duration" in design docs; renamed to avoid
/// shadowing dart:core Duration.
final class NoteValue {
  const NoteValue({
    required this.noteType,
    this.dots = 0,
    this.tupletRatio,
  }) : assert(dots >= 0 && dots <= 4, 'dots must be 0–4');

  final NoteType noteType;

  /// Augmentation dots (0–4).
  final int dots;

  /// e.g., Fraction(2, 3) for triplet (play 3 notes in the time of 2).
  final Fraction? tupletRatio;

  /// Converts to a [Fraction] duration in whole-note units.
  ///
  /// Dots: each adds half the previous value. Tuplet ratio multiplies the result.
  Fraction toFraction() {
    var result = noteType.baseFraction;
    var dotValue = result;
    for (var i = 0; i < dots; i++) {
      dotValue = dotValue / Fraction(2, 1);
      result = result + dotValue;
    }
    final ratio = tupletRatio;
    if (ratio != null) result = result * ratio;
    return result;
  }

  NoteValue copyWith({NoteType? noteType, int? dots, Fraction? tupletRatio}) =>
      NoteValue(
        noteType: noteType ?? this.noteType,
        dots: dots ?? this.dots,
        tupletRatio: tupletRatio ?? this.tupletRatio,
      );

  @override
  bool operator ==(Object other) {
    if (other is! NoteValue) return false;
    return noteType == other.noteType &&
        dots == other.dots &&
        tupletRatio == other.tupletRatio;
  }

  @override
  int get hashCode => Object.hash(noteType, dots, tupletRatio);
}
