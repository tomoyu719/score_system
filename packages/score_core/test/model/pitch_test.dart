import 'package:score_core/src/model/pitch.dart';
import 'package:test/test.dart';

void main() {
  group('Pitch', () {
    group('midiPitch', () {
      test('C4 = 60', () {
        expect(Pitch(step: Step.c, octave: 4).midiPitch, equals(60));
      });

      test('A4 = 69', () {
        expect(Pitch(step: Step.a, octave: 4).midiPitch, equals(69));
      });

      test('C#4 = 61', () {
        expect(
          Pitch(step: Step.c, alter: 1.0, octave: 4).midiPitch,
          equals(61),
        );
      });

      test('Bb4 = 70', () {
        expect(
          Pitch(step: Step.b, alter: -1.0, octave: 4).midiPitch,
          equals(70),
        );
      });

      test('B3 = 59', () {
        expect(Pitch(step: Step.b, octave: 3).midiPitch, equals(59));
      });

      test('C5 = 72', () {
        expect(Pitch(step: Step.c, octave: 5).midiPitch, equals(72));
      });

      test('C0 (lowest) = 12', () {
        expect(Pitch(step: Step.c, octave: 0).midiPitch, equals(12));
      });

      test('G4 = 67', () {
        expect(Pitch(step: Step.g, octave: 4).midiPitch, equals(67));
      });
    });

    group('equality', () {
      test('same pitch is equal', () {
        expect(
          Pitch(step: Step.c, octave: 4),
          equals(Pitch(step: Step.c, octave: 4)),
        );
      });

      test('different octave is not equal', () {
        expect(
          Pitch(step: Step.c, octave: 4),
          isNot(equals(Pitch(step: Step.c, octave: 5))),
        );
      });
    });

    group('copyWith', () {
      test('changes only specified fields', () {
        final p = Pitch(step: Step.c, octave: 4);
        final p2 = p.copyWith(octave: 5);
        expect(p2.step, equals(Step.c));
        expect(p2.octave, equals(5));
        expect(p.octave, equals(4));
      });
    });

    group('diatonicPosition', () {
      test('C0 = 0', () {
        expect(Pitch(step: Step.c, octave: 0).diatonicPosition, equals(0));
      });

      test('C4 = 28', () {
        expect(Pitch(step: Step.c, octave: 4).diatonicPosition, equals(28));
      });

      test('E4 = 30', () {
        expect(Pitch(step: Step.e, octave: 4).diatonicPosition, equals(30));
      });

      test('B4 = 34', () {
        expect(Pitch(step: Step.b, octave: 4).diatonicPosition, equals(34));
      });

      test('C5 = 35', () {
        expect(Pitch(step: Step.c, octave: 5).diatonicPosition, equals(35));
      });

      test('alter does not affect diatonicPosition', () {
        expect(
          Pitch(step: Step.f, octave: 4, alter: 1.0).diatonicPosition,
          equals(Pitch(step: Step.f, octave: 4).diatonicPosition),
        );
      });
    });
  });
}
