import 'package:score_layout/score_layout.dart';
import 'package:test/test.dart';

void main() {
  const engine = StaffSpacingEngine();

  group('StaffSpacingEngine.yForStaff', () {
    test('staff 0 → y = 0.0', () {
      expect(engine.yForStaff(0), 0.0);
    });

    test('staff 1 → y = staffHeight + staffMargin', () {
      expect(engine.yForStaff(1), engine.staffHeight + engine.staffMargin);
    });

    test('staff 2 → y = 2 * (staffHeight + staffMargin)', () {
      expect(engine.yForStaff(2), 2 * (engine.staffHeight + engine.staffMargin));
    });

    test('custom staffHeight and staffMargin', () {
      const custom = StaffSpacingEngine(staffHeight: 5.0, staffMargin: 3.0);
      expect(custom.yForStaff(1), 8.0);
      expect(custom.yForStaff(2), 16.0);
    });
  });

  group('StaffSpacingEngine.yPositionsForExtents', () {
    test('empty extents returns empty list', () {
      expect(engine.yPositionsForExtents([]), isEmpty);
    });

    test('single staff always starts at 0', () {
      const e = StaffExtents();
      expect(engine.yPositionsForExtents([e]), [0.0]);
    });

    test('two staves with no extra → same as yForStaff', () {
      const e = StaffExtents();
      final positions = engine.yPositionsForExtents([e, e]);
      expect(positions[0], 0.0);
      expect(positions[1], closeTo(engine.staffHeight + engine.staffMargin, 1e-9));
    });

    test('below overflow pushes next staff down', () {
      const noExtra = StaffExtents();
      const withBelow = StaffExtents(belowExtra: 3.0);
      final baseline = engine.yPositionsForExtents([noExtra, noExtra]);
      final pushed = engine.yPositionsForExtents([withBelow, noExtra]);
      expect(pushed[1], closeTo(baseline[1] + 3.0, 1e-9));
    });

    test('above overflow on next staff also pushes it down', () {
      const noExtra = StaffExtents();
      const withAbove = StaffExtents(aboveExtra: 2.0);
      final baseline = engine.yPositionsForExtents([noExtra, noExtra]);
      final pushed = engine.yPositionsForExtents([noExtra, withAbove]);
      expect(pushed[1], closeTo(baseline[1] + 2.0, 1e-9));
    });

    test('both below and above add independently', () {
      const below = StaffExtents(belowExtra: 3.0);
      const above = StaffExtents(aboveExtra: 2.0);
      final baseline = engine.yPositionsForExtents([
        const StaffExtents(),
        const StaffExtents(),
      ]);
      final pushed = engine.yPositionsForExtents([below, above]);
      expect(pushed[1], closeTo(baseline[1] + 3.0 + 2.0, 1e-9));
    });

    test('negative extents are clamped to zero', () {
      const negative = StaffExtents(aboveExtra: -5.0, belowExtra: -3.0);
      final withNegative = engine.yPositionsForExtents([negative, negative]);
      final withZero = engine.yPositionsForExtents([
        const StaffExtents(),
        const StaffExtents(),
      ]);
      expect(withNegative[1], closeTo(withZero[1], 1e-9));
    });
  });
}
