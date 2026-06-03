import 'package:score_core/score_core.dart';

/// Calculates X positions and staff-line positions for notes (treble clef).
final class NoteLayout {
  const NoteLayout();

  /// Returns the staff-line index for [pitch] in treble clef.
  ///
  /// 0  = bottom line  (E4)
  /// 1  = first space  (F4)
  /// 2  = second line  (G4)
  /// …
  /// 8  = top line     (F5)
  /// -1 = D4, -2 = C4 (middle C, first ledger line below), …
  ///
  /// Each increment of 1 represents half a staff space (0.5 sp).
  /// [alter] is ignored — it affects accidental rendering, not staff position.
  double staffLineForPitch(Pitch pitch) {
    // Anchor: E4 = 0
    // Steps in treble clef above E4 (ascending): E F G A B C D E ...
    // Each diatonic step = +1 staff line unit
    const stepOrdinal = {
      Step.c: 0,
      Step.d: 1,
      Step.e: 2,
      Step.f: 3,
      Step.g: 4,
      Step.a: 5,
      Step.b: 6,
    };
    // E4 is our reference = staffLine 0
    // E4 has step=e, octave=4 → ordinal position = octave*7 + stepOrdinal[step]
    const stepsPerOctave = 7;
    const referenceOctave = 4;
    const referenceStepOrdinal = 2; // Step.e
    const e4Position = referenceOctave * stepsPerOctave + referenceStepOrdinal;
    final pitchPosition = pitch.octave * stepsPerOctave + stepOrdinal[pitch.step]!;
    return (pitchPosition - e4Position).toDouble();
  }

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
