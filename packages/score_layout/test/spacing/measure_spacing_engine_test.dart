import 'package:fast_immutable_collections/fast_immutable_collections.dart';
import 'package:score_core/score_core.dart';
import 'package:score_layout/score_layout.dart';
import 'package:test/test.dart';

// Isolate sqrt math: no per-note minimum, no measure floor.
const _engine = MeasureSpacingEngine(
  minNoteWidth: 0.0,
  noteSpacing: 4.0,
  minMeasureWidth: 0.0,
);
const _voiceId = VoiceId('v1');

Voice _emptyVoice() => const Voice(id: _voiceId);

Voice _voiceWith(List<NoteType> types) {
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
  return Voice(id: _voiceId, events: IList(events));
}

void main() {
  group('MeasureSpacingEngine.measureWidth', () {
    test('empty voice returns minMeasureWidth', () {
      const e = MeasureSpacingEngine();
      expect(e.measureWidth(_emptyVoice()), e.minMeasureWidth);
    });

    test('single quarter → noteSpacing * sqrt(1) = noteSpacing', () {
      expect(
        _engine.measureWidth(_voiceWith([NoteType.quarter])),
        closeTo(4.0, 1e-9),
      );
    });

    test('single whole → noteSpacing * sqrt(4) = 2 * noteSpacing', () {
      expect(
        _engine.measureWidth(_voiceWith([NoteType.whole])),
        closeTo(8.0, 1e-9),
      );
    });

    test('longer notes produce larger individual widths: whole > half > quarter', () {
      final whole = _engine.measureWidth(_voiceWith([NoteType.whole]));
      final half = _engine.measureWidth(_voiceWith([NoteType.half]));
      final quarter = _engine.measureWidth(_voiceWith([NoteType.quarter]));
      expect(whole, greaterThan(half));
      expect(half, greaterThan(quarter));
    });

    test('sqrt compression: 4 quarters wider than 1 whole (same total duration)', () {
      final oneWhole = _engine.measureWidth(_voiceWith([NoteType.whole]));
      final fourQuarters = _engine.measureWidth(
        _voiceWith([NoteType.quarter, NoteType.quarter, NoteType.quarter, NoteType.quarter]),
      );
      expect(fourQuarters, greaterThan(oneWhole));
    });

    test('minNoteWidth provides per-note floor regardless of duration', () {
      const e = MeasureSpacingEngine(
        minNoteWidth: 1.5,
        noteSpacing: 0.0,
        minMeasureWidth: 0.0,
      );
      expect(e.measureWidth(_voiceWith([NoteType.sixtyFourth])), closeTo(1.5, 1e-9));
    });

    test('total width is always >= minMeasureWidth', () {
      const e = MeasureSpacingEngine();
      expect(
        e.measureWidth(_voiceWith([NoteType.sixtyFourth])),
        greaterThanOrEqualTo(e.minMeasureWidth),
      );
    });

    test('custom noteSpacing reflected', () {
      const e = MeasureSpacingEngine(
        minNoteWidth: 0.0,
        noteSpacing: 6.0,
        minMeasureWidth: 0.0,
      );
      expect(
        e.measureWidth(_voiceWith([NoteType.quarter])),
        closeTo(6.0, 1e-9),
      );
    });
  });

  group('MeasureSpacingEngine.xPositions', () {
    test('empty voices returns empty map', () {
      expect(_engine.xPositions([_emptyVoice()]), isEmpty);
    });

    test('single note at offset 0 → x 0.0', () {
      final voice = _voiceWith([NoteType.quarter]);
      final map = _engine.xPositions([voice]);
      expect(map[Fraction.zero], closeTo(0.0, 1e-9));
    });

    test('two quarters: second note x > first', () {
      final voice = _voiceWith([NoteType.quarter, NoteType.quarter]);
      final map = _engine.xPositions([voice]);
      final x0 = map[Fraction.zero]!;
      final x1 = map[Fraction(1, 4)]!;
      expect(x1, greaterThan(x0));
    });

    test('second quarter x equals width of first quarter', () {
      // With minNoteWidth=0, noteSpacing=4: quarter contributes 4*sqrt(1)=4.
      final voice = _voiceWith([NoteType.quarter, NoteType.quarter]);
      final map = _engine.xPositions([voice]);
      expect(map[Fraction(1, 4)], closeTo(4.0, 1e-9));
    });

    test('cross-voice alignment: same offset maps to same x', () {
      // Voice 1: quarter, quarter, half
      final v1 = Voice(
        id: const VoiceId('v1'),
        events: IList([
          NoteEvent(
            id: const NoteId('n0'),
            offset: Fraction.zero,
            noteValue: const NoteValue(noteType: NoteType.quarter),
            pitch: const Pitch(step: Step.c, octave: 4),
          ),
          NoteEvent(
            id: const NoteId('n1'),
            offset: Fraction(1, 4),
            noteValue: const NoteValue(noteType: NoteType.quarter),
            pitch: const Pitch(step: Step.e, octave: 4),
          ),
        ]),
      );
      // Voice 2: half starting at offset 1/4 (same onset as v1's second note)
      final v2 = Voice(
        id: const VoiceId('v2'),
        events: IList([
          NoteEvent(
            id: const NoteId('n2'),
            offset: Fraction(1, 4),
            noteValue: const NoteValue(noteType: NoteType.half),
            pitch: const Pitch(step: Step.g, octave: 4),
          ),
        ]),
      );
      final map = _engine.xPositions([v1, v2]);
      // Both events at offset 1/4 must share the same x.
      expect(map[Fraction(1, 4)], isNotNull);
      // The position is determined once from the shared grid, not per-voice.
      expect(map.keys.where((k) => k == Fraction(1, 4)).length, equals(1));
    });
  });
}
