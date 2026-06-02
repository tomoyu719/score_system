import 'package:score_layout/score_layout.dart';
import 'package:test/test.dart';

void main() {
  const policy = StemDirectionPolicy();

  group('StemDirectionPolicy', () {
    test('staffLine < 4 → stem up', () {
      expect(policy.stemDirection(0.0), StemDirection.up);
      expect(policy.stemDirection(1.0), StemDirection.up);
      expect(policy.stemDirection(3.0), StemDirection.up);
      expect(policy.stemDirection(3.9), StemDirection.up);
    });

    test('staffLine == 4 (middle line) → stem down', () {
      expect(policy.stemDirection(4.0), StemDirection.down);
    });

    test('staffLine > 4 → stem down', () {
      expect(policy.stemDirection(5.0), StemDirection.down);
      expect(policy.stemDirection(8.0), StemDirection.down);
    });
  });
}
