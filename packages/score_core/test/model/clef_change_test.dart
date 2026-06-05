import 'package:fast_immutable_collections/fast_immutable_collections.dart';
import 'package:score_core/score_core.dart';
import 'package:test/test.dart';

void main() {
  group('ClefChange', () {
    test('defaults offset to Fraction.zero', () {
      const cc = ClefChange(clef: Clef.treble, measureNumber: 1);
      expect(cc.offset, equals(Fraction.zero));
    });

    test('equality is value-based', () {
      const a = ClefChange(clef: Clef.bass, measureNumber: 2);
      const b = ClefChange(clef: Clef.bass, measureNumber: 2);
      expect(a, equals(b));
    });
  });

  group('Staff.effectiveClefAt', () {
    test('default staff returns treble at any position', () {
      final staff = Staff(id: const StaffId('s1'));
      expect(staff.effectiveClefAt(1, Fraction.zero), Clef.treble);
      expect(staff.effectiveClefAt(99, Fraction(3, 4)), Clef.treble);
    });

    test('returns the clef active at the queried position', () {
      final staff = Staff(
        id: const StaffId('s1'),
        clefChanges: IList([
          const ClefChange(clef: Clef.treble, measureNumber: 1),
          ClefChange(clef: Clef.bass, measureNumber: 3, offset: Fraction(1, 2)),
        ]),
      );
      expect(staff.effectiveClefAt(2, Fraction.zero), Clef.treble);
      expect(staff.effectiveClefAt(3, Fraction(1, 4)), Clef.treble); // before change
      expect(staff.effectiveClefAt(3, Fraction(1, 2)), Clef.bass);   // at change point
      expect(staff.effectiveClefAt(4, Fraction.zero), Clef.bass);    // after change
    });

    test('falls back to first clef when all changes are after the query', () {
      final staff = Staff(
        id: const StaffId('s1'),
        clefChanges: IList([
          const ClefChange(clef: Clef.bass, measureNumber: 5),
        ]),
      );
      // No change at or before m1 — falls back to first entry
      expect(staff.effectiveClefAt(1, Fraction.zero), Clef.bass);
    });
  });
}
