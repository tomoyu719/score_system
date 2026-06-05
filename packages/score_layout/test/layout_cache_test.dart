import 'package:fast_immutable_collections/fast_immutable_collections.dart';
import 'package:score_core/score_core.dart';
import 'package:score_layout/score_layout.dart';
import 'package:test/test.dart';

MeasureLayout _measure(int n) =>
    MeasureLayout(measureNumber: n, relativeWidth: 1.0);

Score _simpleScore() => Score(
      id: const ScoreId('s'),
      parts: IList([
        Part(
          id: const PartId('p1'),
          name: 'Piano',
          staves: IList([
            Staff(
              id: const StaffId('s1'),
              measures: IMap({
                1: Measure(
                  id: const MeasureId('m1'),
                  voices: IMap({
                    const VoiceId('v1'): Voice(
                      id: const VoiceId('v1'),
                      events: IList([
                        NoteEvent(
                          id: const NoteId('n1'),
                          offset: Fraction.zero,
                          noteValue: NoteValue(noteType: NoteType.quarter),
                          pitch: const Pitch(step: Step.c, octave: 4),
                        ),
                      ]),
                    ),
                  }),
                ),
              }),
            ),
          ]),
        ),
      ]),
      measureHeaders: IList([
        MeasureHeader(
          measureNumber: 1,
          timeSignature: const TimeSignature(beats: 4, beatType: 4),
          keySignature: const KeySignature(fifths: 0),
        ),
      ]),
    );

void main() {
  group('LayoutCache', () {
    test('get on empty cache returns null', () {
      expect(const LayoutCache().get(1), isNull);
    });

    test('put then get returns the layout', () {
      final cache = const LayoutCache().put(1, _measure(1));
      expect(cache.get(1), equals(_measure(1)));
    });

    test('invalidate removes specified measures', () {
      final cache = const LayoutCache().put(1, _measure(1)).put(2, _measure(2));
      final after = cache.invalidate({1});
      expect(after.get(1), isNull);
      expect(after.get(2), equals(_measure(2)));
    });

    test('clear removes all measures', () {
      final cache = const LayoutCache().put(1, _measure(1)).put(2, _measure(2));
      expect(cache.clear().get(1), isNull);
      expect(cache.clear().get(2), isNull);
    });

    test('does not mutate original on put', () {
      final original = const LayoutCache();
      original.put(1, _measure(1));
      expect(original.get(1), isNull);
    });
  });

  group('calculateIncremental', () {
    test('returns a LayoutTree and populates cache', () {
      final score = _simpleScore();
      final (tree, cache) = calculateIncremental(score, const LayoutCache());
      expect(tree.systems, hasLength(1));
      expect(cache.get(1), isNotNull);
    });

    test('calling twice produces same tree', () {
      final score = _simpleScore();
      final (tree1, cache1) = calculateIncremental(score, const LayoutCache());
      final (tree2, _) = calculateIncremental(score, cache1);
      expect(tree1, equals(tree2));
    });
  });
}
