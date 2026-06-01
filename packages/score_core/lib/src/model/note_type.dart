import 'fraction.dart';

/// Note duration types, from whole to sixty-fourth.
enum NoteType {
  whole,
  half,
  quarter,
  eighth,
  sixteenth,
  thirtySecond,
  sixtyFourth;

  Fraction get baseFraction => switch (this) {
        whole => Fraction(1, 1),
        half => Fraction(1, 2),
        quarter => Fraction(1, 4),
        eighth => Fraction(1, 8),
        sixteenth => Fraction(1, 16),
        thirtySecond => Fraction(1, 32),
        sixtyFourth => Fraction(1, 64),
      };
}
