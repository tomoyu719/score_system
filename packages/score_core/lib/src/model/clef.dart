import 'pitch.dart';

/// Standard musical clef types.
enum Clef {
  /// G clef: bottom staff line is E4.
  treble,

  /// F clef: bottom staff line is G2.
  bass,

  /// C clef on middle (third) line: bottom staff line is F3.
  alto,

  /// C clef on fourth line: bottom staff line is D3.
  tenor;

  /// The [Pitch.diatonicPosition] that maps to staff line 0 (bottom line).
  int get referenceDiatonicPosition => switch (this) {
        treble => 4 * 7 + 2, // E4
        bass => 2 * 7 + 4, // G2
        alto => 3 * 7 + 3, // F3
        tenor => 3 * 7 + 1, // D3
      };
}
