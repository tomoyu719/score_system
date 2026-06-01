import 'package:fast_immutable_collections/fast_immutable_collections.dart';
import 'package:score_core/src/ids.dart';
import 'package:score_core/src/model/key_signature.dart';
import 'package:score_core/src/model/measure_header.dart';
import 'package:score_core/src/model/part.dart';
import 'package:score_core/src/model/score.dart';
import 'package:score_core/src/model/time_signature.dart';
import 'package:test/test.dart';

Score _emptyScore() => Score(id: const ScoreId('s1'));

void main() {
  group('Score', () {
    test('empty score has no parts', () {
      expect(_emptyScore().parts.isEmpty, isTrue);
    });

    test('title defaults to empty', () {
      expect(_emptyScore().title, isEmpty);
    });

    test('copyWith title does not affect parts', () {
      final score = _emptyScore();
      final titled = score.copyWith(title: 'Symphony No. 5');
      expect(titled.title, equals('Symphony No. 5'));
      expect(titled.parts, same(score.parts)); // structural sharing
    });

    test('copyWith parts replaces parts list', () {
      final score = _emptyScore();
      final part = Part(id: const PartId('p1'), name: 'Violin');
      final updated = score.copyWith(parts: IList([part]));
      expect(updated.parts.length, equals(1));
      expect(score.parts.isEmpty, isTrue);
    });

    test('headerForMeasure returns correct header', () {
      const ts = TimeSignature(beats: 4, beatType: 4);
      const ks = KeySignature(fifths: 0);
      final h1 = MeasureHeader(
        measureNumber: 1,
        timeSignature: ts,
        keySignature: ks,
      );
      final h2 = MeasureHeader(
        measureNumber: 2,
        timeSignature: ts,
        keySignature: ks,
      );
      final score = _emptyScore().copyWith(
        measureHeaders: IList([h1, h2]),
      );
      expect(score.headerForMeasure(1), equals(h1));
      expect(score.headerForMeasure(2), equals(h2));
      expect(score.headerForMeasure(99), isNull);
    });

    test('immutability: original unchanged after copyWith', () {
      final original = _emptyScore();
      original.copyWith(
        title: 'New',
        parts: IList([Part(id: const PartId('p1'), name: 'Piano')]),
      );
      expect(original.title, isEmpty);
      expect(original.parts.isEmpty, isTrue);
    });
  });
}
