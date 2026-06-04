import 'package:score_core/score_core.dart';
import 'package:score_layout/score_layout.dart';
import 'package:test/test.dart';

void main() {
  const calc = RestPositioningCalculator();

  Voice voice({
    RestPositioningPolicy policy = RestPositioningPolicy.auto,
    int priority = 0,
    int voiceNumber = 1,
  }) =>
      Voice(
        id: const VoiceId('v1'),
        restPositioningPolicy: policy,
        priority: priority,
        voiceNumber: voiceNumber,
      );

  group('RestPositioningCalculator', () {
    test('center policy → 4', () {
      expect(calc.resolve(voice(policy: RestPositioningPolicy.center), 2), equals(4));
    });

    test('byVoice, voiceNumber 1 → 4', () {
      expect(calc.resolve(voice(policy: RestPositioningPolicy.byVoice, voiceNumber: 1), 2), equals(4));
    });

    test('byVoice, voiceNumber 2 → 6', () {
      expect(calc.resolve(voice(policy: RestPositioningPolicy.byVoice, voiceNumber: 2), 2), equals(6));
    });

    test('auto, single voice → 4 (center)', () {
      expect(calc.resolve(voice(), 1), equals(4));
    });

    test('auto, multi-voice, priority 0 → 6 (upper)', () {
      expect(calc.resolve(voice(priority: 0), 2), equals(6));
    });

    test('auto, multi-voice, priority 1 → 2 (lower)', () {
      expect(calc.resolve(voice(priority: 1), 2), equals(2));
    });
  });
}
