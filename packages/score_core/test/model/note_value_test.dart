import 'package:score_core/src/model/fraction.dart';
import 'package:score_core/src/model/note_type.dart';
import 'package:score_core/src/model/note_value.dart';
import 'package:test/test.dart';

void main() {
  group('NoteType', () {
    test('quarter base fraction is 1/4', () {
      expect(NoteType.quarter.baseFraction, equals(Fraction(1, 4)));
    });

    test('whole base fraction is 1/1', () {
      expect(NoteType.whole.baseFraction, equals(Fraction(1, 1)));
    });

    test('half base fraction is 1/2', () {
      expect(NoteType.half.baseFraction, equals(Fraction(1, 2)));
    });

    test('eighth base fraction is 1/8', () {
      expect(NoteType.eighth.baseFraction, equals(Fraction(1, 8)));
    });

    test('sixteenth base fraction is 1/16', () {
      expect(NoteType.sixteenth.baseFraction, equals(Fraction(1, 16)));
    });
  });

  group('NoteValue', () {
    group('undotted', () {
      test('quarter = 1/4', () {
        expect(
          NoteValue(noteType: NoteType.quarter).toFraction(),
          equals(Fraction(1, 4)),
        );
      });

      test('whole = 1/1', () {
        expect(
          NoteValue(noteType: NoteType.whole).toFraction(),
          equals(Fraction(1, 1)),
        );
      });

      test('half = 1/2', () {
        expect(
          NoteValue(noteType: NoteType.half).toFraction(),
          equals(Fraction(1, 2)),
        );
      });
    });

    group('dotted', () {
      test('dotted quarter = 3/8', () {
        expect(
          NoteValue(noteType: NoteType.quarter, dots: 1).toFraction(),
          equals(Fraction(3, 8)),
        );
      });

      test('dotted half = 3/4', () {
        expect(
          NoteValue(noteType: NoteType.half, dots: 1).toFraction(),
          equals(Fraction(3, 4)),
        );
      });

      test('double-dotted quarter = 7/16', () {
        expect(
          NoteValue(noteType: NoteType.quarter, dots: 2).toFraction(),
          equals(Fraction(7, 16)),
        );
      });

      test('double-dotted half = 7/8', () {
        expect(
          NoteValue(noteType: NoteType.half, dots: 2).toFraction(),
          equals(Fraction(7, 8)),
        );
      });
    });

    group('tuplet', () {
      test('triplet quarter = 1/6', () {
        expect(
          NoteValue(
            noteType: NoteType.quarter,
            tupletRatio: Fraction(2, 3),
          ).toFraction(),
          equals(Fraction(1, 6)),
        );
      });

      test('quintuplet eighth = 1/10', () {
        // 5 notes in the space of 4 eighths: ratio = 4/5, result = 1/8 * 4/5 = 1/10
        expect(
          NoteValue(
            noteType: NoteType.eighth,
            tupletRatio: Fraction(4, 5),
          ).toFraction(),
          equals(Fraction(1, 10)),
        );
      });
    });

    group('copyWith', () {
      test('changes only specified fields', () {
        final original = NoteValue(noteType: NoteType.quarter, dots: 1);
        final modified = original.copyWith(dots: 0);
        expect(modified.noteType, equals(NoteType.quarter));
        expect(modified.dots, equals(0));
        expect(original.dots, equals(1));
      });
    });
  });
}
