import 'package:score_core/score_core.dart';
import 'package:score_layout/score_layout.dart';
import 'package:test/test.dart';

void main() {
  const calc = StemDirectionCalculator();

  Voice voice({
    StemDirection policy = StemDirection.auto,
    int priority = 0,
  }) =>
      Voice(id: const VoiceId('v1'), stemDirectionPolicy: policy, priority: priority);

  group('StemDirectionCalculator', () {
    test('explicit up → up', () {
      expect(calc.resolve(voice(policy: StemDirection.up), 2), equals(StemDirection.up));
    });

    test('explicit down → down', () {
      expect(calc.resolve(voice(policy: StemDirection.down), 1), equals(StemDirection.down));
    });

    test('auto, single voice → down', () {
      expect(calc.resolve(voice(), 1), equals(StemDirection.down));
    });

    test('auto, 2-voice, priority 0 → up', () {
      expect(calc.resolve(voice(priority: 0), 2), equals(StemDirection.up));
    });

    test('auto, 2-voice, priority 1 → down', () {
      expect(calc.resolve(voice(priority: 1), 2), equals(StemDirection.down));
    });

    test('auto, 3-voice, priority 2 → down', () {
      expect(calc.resolve(voice(priority: 2), 3), equals(StemDirection.down));
    });
  });
}
