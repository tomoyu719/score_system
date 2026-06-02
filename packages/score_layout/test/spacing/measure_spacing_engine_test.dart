import 'package:fast_immutable_collections/fast_immutable_collections.dart';
import 'package:score_core/score_core.dart';
import 'package:score_layout/score_layout.dart';
import 'package:test/test.dart';

void main() {
  // Use minMeasureWidth=0 to isolate spacing math from the minimum-width floor.
  const engine = MeasureSpacingEngine(minMeasureWidth: 0.0);
  const voiceId = VoiceId('v1');

  Voice emptyVoice() => const Voice(id: voiceId);

  Voice voiceWith(List<NoteType> types) {
    var offset = Fraction.zero;
    final events = <MusicEvent>[];
    for (final t in types) {
      final nv = NoteValue(noteType: t);
      events.add(
        NoteEvent(
          id: NoteId('n${events.length}'),
          offset: offset,
          noteValue: nv,
          pitch: const Pitch(step: Step.c, octave: 4),
        ),
      );
      offset = offset + nv.toFraction();
    }
    return Voice(id: voiceId, events: IList(events));
  }

  group('MeasureSpacingEngine', () {
    test('empty voice returns minMeasureWidth', () {
      const defaultEngine = MeasureSpacingEngine();
      final width = defaultEngine.measureWidth(emptyVoice(), Fraction(1, 1));
      expect(width, defaultEngine.minMeasureWidth);
    });

    test('4 quarter notes in 4/4 → noteSpacing * 4', () {
      final voice = voiceWith([
        NoteType.quarter,
        NoteType.quarter,
        NoteType.quarter,
        NoteType.quarter,
      ]);
      final width = engine.measureWidth(voice, Fraction(1, 1));
      expect(width, engine.noteSpacing * 4);
    });

    test('width is always >= minMeasureWidth', () {
      const defaultEngine = MeasureSpacingEngine();
      final voice = voiceWith([NoteType.sixtyFourth]);
      final width = defaultEngine.measureWidth(voice, Fraction(1, 1));
      expect(width, greaterThanOrEqualTo(defaultEngine.minMeasureWidth));
    });

    test('half note contributes noteSpacing * 2', () {
      final voice = voiceWith([NoteType.half, NoteType.half]);
      final width = engine.measureWidth(voice, Fraction(1, 1));
      // Each half = 1/2 of whole = 2 * (1/2 / (1/4)) = 2 quarters each → 4 quarters total
      expect(width, engine.noteSpacing * 4);
    });

    test('custom noteSpacing reflected', () {
      const customEngine = MeasureSpacingEngine(noteSpacing: 6.0);
      final voice = voiceWith([
        NoteType.quarter,
        NoteType.quarter,
        NoteType.quarter,
        NoteType.quarter,
      ]);
      final width = customEngine.measureWidth(voice, Fraction(1, 1));
      expect(width, 24.0);
    });
  });
}
