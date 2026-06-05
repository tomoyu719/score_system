import 'clef.dart';
import 'fraction.dart';

/// A clef that takes effect at a specific position within a staff.
final class ClefChange {
  const ClefChange({
    required this.clef,
    required this.measureNumber,
    this.offset = Fraction.zero,
  });

  final Clef clef;

  /// 1-based measure number at which this clef becomes active.
  final int measureNumber;

  /// Beat offset within [measureNumber] at which this clef becomes active.
  final Fraction offset;

  @override
  bool operator ==(Object other) =>
      other is ClefChange &&
      clef == other.clef &&
      measureNumber == other.measureNumber &&
      offset == other.offset;

  @override
  int get hashCode => Object.hash(clef, measureNumber, offset);
}
