import 'package:score_core/score_core.dart';
import 'package:score_layout/score_layout.dart';
import 'package:test/test.dart';

void main() {
  const layout = NoteLayout();

  group('NoteLayout.staffLineForPitch (treble clef)', () {
    test('E4 → staffLine 0 (bottom line)', () {
      expect(
        layout.staffLineForPitch(
          const Pitch(step: Step.e, octave: 4),
        ),
        0.0,
      );
    });

    test('F4 → staffLine 1', () {
      expect(
        layout.staffLineForPitch(
          const Pitch(step: Step.f, octave: 4),
        ),
        1.0,
      );
    });

    test('G4 → staffLine 2', () {
      expect(
        layout.staffLineForPitch(
          const Pitch(step: Step.g, octave: 4),
        ),
        2.0,
      );
    });

    test('A4 → staffLine 3', () {
      expect(
        layout.staffLineForPitch(
          const Pitch(step: Step.a, octave: 4),
        ),
        3.0,
      );
    });

    test('B4 → staffLine 4 (middle line)', () {
      expect(
        layout.staffLineForPitch(
          const Pitch(step: Step.b, octave: 4),
        ),
        4.0,
      );
    });

    test('C5 → staffLine 5', () {
      expect(
        layout.staffLineForPitch(
          const Pitch(step: Step.c, octave: 5),
        ),
        5.0,
      );
    });

    test('D5 → staffLine 6', () {
      expect(
        layout.staffLineForPitch(
          const Pitch(step: Step.d, octave: 5),
        ),
        6.0,
      );
    });

    test('E5 → staffLine 7', () {
      expect(
        layout.staffLineForPitch(
          const Pitch(step: Step.e, octave: 5),
        ),
        7.0,
      );
    });

    test('F5 → staffLine 8 (top line)', () {
      expect(
        layout.staffLineForPitch(
          const Pitch(step: Step.f, octave: 5),
        ),
        8.0,
      );
    });

    test('D4 → staffLine -1', () {
      expect(
        layout.staffLineForPitch(
          const Pitch(step: Step.d, octave: 4),
        ),
        -1.0,
      );
    });

    test('C4 (middle C) → staffLine -2 (first ledger line below)', () {
      expect(
        layout.staffLineForPitch(
          const Pitch(step: Step.c, octave: 4),
        ),
        -2.0,
      );
    });

    test('B3 → staffLine -3', () {
      expect(
        layout.staffLineForPitch(
          const Pitch(step: Step.b, octave: 3),
        ),
        -3.0,
      );
    });

    test('alter does not change staff line position', () {
      final natural = layout.staffLineForPitch(
        const Pitch(step: Step.f, octave: 4),
      );
      final sharp = layout.staffLineForPitch(
        const Pitch(step: Step.f, octave: 4, alter: 1.0),
      );
      expect(natural, sharp);
    });
  });

  group('NoteLayout.xForOffset', () {
    test('offset 0 → x 0.0', () {
      expect(
        layout.xForOffset(
          Fraction(0, 1),
          Fraction(1, 1),
          20.0,
        ),
        0.0,
      );
    });

    test('offset 1/4 of 1/1 in 20sp → 5.0', () {
      expect(
        layout.xForOffset(
          Fraction(1, 4),
          Fraction(1, 1),
          20.0,
        ),
        5.0,
      );
    });

    test('offset 1/2 of 1/1 in 20sp → 10.0', () {
      expect(
        layout.xForOffset(
          Fraction(1, 2),
          Fraction(1, 1),
          20.0,
        ),
        10.0,
      );
    });

    test('offset 3/4 of 1/1 in 20sp → 15.0', () {
      expect(
        layout.xForOffset(
          Fraction(3, 4),
          Fraction(1, 1),
          20.0,
        ),
        15.0,
      );
    });
  });
}
