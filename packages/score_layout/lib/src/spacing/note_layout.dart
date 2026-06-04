import 'package:score_core/score_core.dart';

/// Calculates X positions and staff-line positions for notes.
final class NoteLayout {
  const NoteLayout();

  /// Returns the staff-line index for [pitch] in [clef].
  ///
  /// 0  = bottom line, each integer step = one diatonic step (0.5 sp visually).
  /// Negative values are ledger lines below the staff.
  /// [alter] is ignored — it affects accidental rendering, not staff position.
  double staffLineForPitch(Pitch pitch, [Clef clef = Clef.treble]) =>
      (pitch.diatonicPosition - clef.referenceDiatonicPosition).toDouble();

  /// Returns the X offset (in sp) for a note at [offset] within a measure of
  /// [measureDuration], given a total [measureWidth] in sp.
  double xForOffset(
    Fraction offset,
    Fraction measureDuration,
    double measureWidth,
  ) {
    if (measureDuration.isZero) return 0.0;
    final ratio = offset.toDouble() / measureDuration.toDouble();
    return ratio * measureWidth;
  }
}
