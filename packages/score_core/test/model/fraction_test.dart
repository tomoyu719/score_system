import 'package:score_core/src/model/fraction.dart';
import 'package:test/test.dart';

void main() {
  group('Fraction', () {
    group('equality and reduction', () {
      test('6/4 equals 3/2', () {
        expect(Fraction(6, 4), equals(Fraction(3, 2)));
      });

      test('2/4 equals 1/2', () {
        expect(Fraction(2, 4), equals(Fraction(1, 2)));
      });

      test('same values are equal', () {
        expect(Fraction(3, 4), equals(Fraction(3, 4)));
      });

      test('stores in reduced form', () {
        final f = Fraction(6, 4);
        expect(f.numerator, equals(3));
        expect(f.denominator, equals(2));
      });
    });

    group('arithmetic', () {
      test('1/2 + 1/2 = 1', () {
        expect(Fraction(1, 2) + Fraction(1, 2), equals(Fraction(1, 1)));
      });

      test('1/3 + 1/6 = 1/2', () {
        expect(Fraction(1, 3) + Fraction(1, 6), equals(Fraction(1, 2)));
      });

      test('3/4 - 1/4 = 1/2', () {
        expect(Fraction(3, 4) - Fraction(1, 4), equals(Fraction(1, 2)));
      });

      test('1/2 * 2/3 = 1/3', () {
        expect(Fraction(1, 2) * Fraction(2, 3), equals(Fraction(1, 3)));
      });

      test('1/2 / 2 = 1/4', () {
        expect(Fraction(1, 2) / Fraction(2, 1), equals(Fraction(1, 4)));
      });

      test('5-tuplet: 1/5 * 5 = 1', () {
        expect(Fraction(1, 5) * Fraction(5, 1), equals(Fraction(1, 1)));
      });

      test('unary minus', () {
        expect(-Fraction(3, 4), equals(Fraction(-3, 4)));
      });
    });

    group('comparison', () {
      test('3/4 > 1/2', () {
        expect(Fraction(3, 4) > Fraction(1, 2), isTrue);
      });

      test('1/4 < 1/2', () {
        expect(Fraction(1, 4) < Fraction(1, 2), isTrue);
      });

      test('1/2 >= 1/2', () {
        expect(Fraction(1, 2) >= Fraction(1, 2), isTrue);
      });

      test('1/2 <= 3/4', () {
        expect(Fraction(1, 2) <= Fraction(3, 4), isTrue);
      });

      test('compareTo returns 0 for equal fractions', () {
        expect(Fraction(2, 4).compareTo(Fraction(1, 2)), equals(0));
      });
    });

    group('special values', () {
      test('zero', () {
        expect(Fraction.zero, equals(Fraction(0, 1)));
      });

      test('one', () {
        expect(Fraction.one, equals(Fraction(1, 1)));
      });

      test('isZero', () {
        expect(Fraction.zero.isZero, isTrue);
        expect(Fraction(1, 4).isZero, isFalse);
      });

      test('isNegative', () {
        expect((-Fraction(1, 4)).isNegative, isTrue);
        expect(Fraction(1, 4).isNegative, isFalse);
      });
    });

    group('string conversion', () {
      test('toString produces p/q format', () {
        expect(Fraction(3, 4).toString(), equals('3/4'));
      });

      test('fromString round-trip', () {
        expect(Fraction.fromString('3/4').toString(), equals('3/4'));
      });

      test('fromString parses whole number', () {
        expect(Fraction.fromString('1'), equals(Fraction(1, 1)));
      });

      test('fromString parses reduced fraction', () {
        expect(Fraction.fromString('1/2'), equals(Fraction(1, 2)));
      });
    });

    group('negative fractions', () {
      test('negative numerator is preserved', () {
        expect(Fraction(-1, 2).isNegative, isTrue);
      });

      test('negative denominator is normalized to positive denom', () {
        final f = Fraction(1, -2);
        expect(f.denominator, greaterThan(0));
        expect(f.isNegative, isTrue);
      });
    });

    group('toDouble', () {
      test('1/2 = 0.5', () {
        expect(Fraction(1, 2).toDouble(), closeTo(0.5, 1e-10));
      });
    });
  });
}
