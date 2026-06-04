import 'package:fast_immutable_collections/fast_immutable_collections.dart';
import 'package:score_core/score_core.dart';
import 'package:score_layout/score_layout.dart';
import 'package:test/test.dart';

MeasureHeader header(int n, int beats, int beatType) => MeasureHeader(
      measureNumber: n,
      timeSignature: TimeSignature(beats: beats, beatType: beatType),
      keySignature: const KeySignature(fifths: 0),
    );

Score scoreWithHeaders(List<MeasureHeader> headers) => Score(
      id: const ScoreId('s'),
      measureHeaders: IList(headers),
    );

void main() {
  const engine = MeasureSpacingEngine();

  group('MeasureSpacingEngine', () {
    test('empty score returns empty list', () {
      expect(engine.calculate(Score(id: const ScoreId('s'))), isEmpty);
    });

    test('single measure → relativeWidth 1.0', () {
      final result = engine.calculate(scoreWithHeaders([header(1, 4, 4)]));
      expect(result, hasLength(1));
      expect(result.first.relativeWidth, equals(1.0));
    });

    test('4/4 and 2/4 → ratio 2:1', () {
      final result = engine.calculate(scoreWithHeaders([
        header(1, 4, 4), // duration 1/1
        header(2, 2, 4), // duration 1/2
      ]));
      expect(result[0].relativeWidth, equals(2.0));
      expect(result[1].relativeWidth, equals(1.0));
    });

    test('measures listed in header order', () {
      final result = engine.calculate(scoreWithHeaders([
        header(1, 4, 4),
        header(2, 3, 4),
      ]));
      expect(result[0].measureNumber, equals(1));
      expect(result[1].measureNumber, equals(2));
    });

    test('3/4 and 4/4 → ratio 3:4 (min measure=1.0)', () {
      final result = engine.calculate(scoreWithHeaders([
        header(1, 3, 4), // 3/4
        header(2, 4, 4), // 4/4
      ]));
      expect(result[0].relativeWidth, closeTo(1.0, 1e-9)); // 3/4 is min
      expect(result[1].relativeWidth, closeTo(4 / 3, 1e-9));
    });
  });
}
