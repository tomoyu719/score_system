import 'package:score_core/score_core.dart';

/// Converts a [Pitch] to a logical staff-line number for a given [Clef].
///
/// Staff-line numbering: 0 = bottom line of the staff, positive = upward.
/// Lines and spaces interleave: line 0, space 1, line 2, space 3, line 4 …
///
/// Pitched notes use this mapper (clef-dependent / "gentle" positioning).
/// Percussion notes use [DrumInstrument.staffLine] directly (clef-independent).
final class ClefStaffLineMapper {
  const ClefStaffLineMapper();

  static const _stepIndex = {
    Step.c: 0,
    Step.d: 1,
    Step.e: 2,
    Step.f: 3,
    Step.g: 4,
    Step.a: 5,
    Step.b: 6,
  };

  // Reference pitch for each clef: the pitch that sits on staffLine 0.
  static const _refStep = {
    Clef.treble: Step.e,
    Clef.bass: Step.g,
    Clef.alto: Step.f,
    Clef.tenor: Step.d,
  };

  static const _refOctave = {
    Clef.treble: 4,
    Clef.bass: 2,
    Clef.alto: 3,
    Clef.tenor: 3,
  };

  /// Returns the staff-line position for [pitch] under [clef].
  ///
  /// Returns 0 for [Clef.percussion] (position determined by instrument).
  int map(Pitch pitch, Clef clef) {
    if (clef == Clef.percussion) return 0;
    final refStep = _refStep[clef]!;
    final refOctave = _refOctave[clef]!;
    return 7 * (pitch.octave - refOctave) +
        _stepIndex[pitch.step]! -
        _stepIndex[refStep]!;
  }

  /// Accidental type string from a pitch's [alter] value, or null if natural.
  static String? accidentalType(double alter) {
    if (alter == 1.0) return 'sharp';
    if (alter == -1.0) return 'flat';
    if (alter == 2.0) return 'doubleSharp';
    if (alter == -2.0) return 'doubleFlat';
    return null;
  }
}
