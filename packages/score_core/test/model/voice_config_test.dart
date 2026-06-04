import 'package:fast_immutable_collections/fast_immutable_collections.dart';
import 'package:score_core/score_core.dart';
import 'package:test/test.dart';

void main() {
  group('StemDirection', () {
    test('has expected values', () {
      expect(StemDirection.values, containsAll([StemDirection.up, StemDirection.down, StemDirection.auto]));
    });
  });

  group('RestPositioningPolicy', () {
    test('has expected values', () {
      expect(RestPositioningPolicy.values, containsAll([
        RestPositioningPolicy.auto,
        RestPositioningPolicy.center,
        RestPositioningPolicy.byVoice,
      ]));
    });
  });

  group('Voice VoiceConfig fields', () {
    test('defaults are sensible', () {
      final v = Voice(id: const VoiceId('v1'));
      expect(v.voiceNumber, equals(1));
      expect(v.priority, equals(0));
      expect(v.stemDirectionPolicy, equals(StemDirection.auto));
      expect(v.restPositioningPolicy, equals(RestPositioningPolicy.auto));
      expect(v.isHidden, isFalse);
      expect(v.isPlayback, isFalse);
    });

    test('all fields can be set', () {
      final v = Voice(
        id: const VoiceId('v1'),
        voiceNumber: 2,
        priority: 10,
        stemDirectionPolicy: StemDirection.up,
        restPositioningPolicy: RestPositioningPolicy.byVoice,
        isHidden: true,
        isPlayback: true,
      );
      expect(v.voiceNumber, equals(2));
      expect(v.priority, equals(10));
      expect(v.stemDirectionPolicy, equals(StemDirection.up));
      expect(v.restPositioningPolicy, equals(RestPositioningPolicy.byVoice));
      expect(v.isHidden, isTrue);
      expect(v.isPlayback, isTrue);
    });

    test('copyWith overrides only specified fields', () {
      final original = Voice(
        id: const VoiceId('v1'),
        voiceNumber: 1,
        priority: 5,
        stemDirectionPolicy: StemDirection.down,
      );
      final copy = original.copyWith(priority: 0, isHidden: true);
      expect(copy.id, equals(original.id));
      expect(copy.voiceNumber, equals(1));
      expect(copy.priority, equals(0));
      expect(copy.stemDirectionPolicy, equals(StemDirection.down));
      expect(copy.isHidden, isTrue);
    });

    test('copyWith preserves events', () {
      final note = NoteEvent(
        id: const NoteId('n1'),
        offset: Fraction.zero,
        noteValue: NoteValue(noteType: NoteType.quarter),
        pitch: const Pitch(step: Step.c, octave: 4),
      );
      final v = Voice(id: const VoiceId('v1'), events: IList([note]));
      final copy = v.copyWith(voiceNumber: 2);
      expect(copy.events, hasLength(1));
    });
  });

  group('Measure.voicesSortedByPriority', () {
    test('returns voices sorted by priority ascending', () {
      const v1 = VoiceId('v1');
      const v2 = VoiceId('v2');
      const v3 = VoiceId('v3');
      final measure = Measure(
        id: const MeasureId('m1'),
        voices: IMap({
          v1: Voice(id: v1, priority: 5, voiceNumber: 1),
          v2: Voice(id: v2, priority: 0, voiceNumber: 2),
          v3: Voice(id: v3, priority: 2, voiceNumber: 3),
        }),
      );
      final sorted = measure.voicesSortedByPriority.toList();
      expect(sorted[0].id, equals(v2)); // priority 0
      expect(sorted[1].id, equals(v3)); // priority 2
      expect(sorted[2].id, equals(v1)); // priority 5
    });

    test('breaks ties by voiceNumber', () {
      const v1 = VoiceId('v1');
      const v2 = VoiceId('v2');
      final measure = Measure(
        id: const MeasureId('m1'),
        voices: IMap({
          v1: Voice(id: v1, priority: 0, voiceNumber: 2),
          v2: Voice(id: v2, priority: 0, voiceNumber: 1),
        }),
      );
      final sorted = measure.voicesSortedByPriority.toList();
      expect(sorted[0].id, equals(v2)); // voiceNumber 1 first
      expect(sorted[1].id, equals(v1)); // voiceNumber 2 second
    });

    test('returns empty iterable for empty measure', () {
      final measure = Measure(id: const MeasureId('m1'));
      expect(measure.voicesSortedByPriority, isEmpty);
    });
  });
}
