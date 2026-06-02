import 'package:score_layout/score_layout.dart';
import 'package:test/test.dart';

void main() {
  const engine = StaffSpacingEngine();

  group('StaffSpacingEngine', () {
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
}
