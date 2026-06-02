import 'package:score_layout/score_layout.dart';
import 'package:test/test.dart';

void main() {
  const detector = CollisionDetector();

  NoteheadElement makeNote(String id, BoundingBox bounds,
      {bool manual = false}) =>
      NoteheadElement(
        id: id,
        bounds: bounds,
        noteId: id,
        midiPitch: 60,
        staffLine: 0,
        isManualOverride: manual,
      );

  group('CollisionDetector', () {
    test('two overlapping boxes → 1 pair detected', () {
      final a = makeNote(
        'a',
        const BoundingBox(x: 0, y: 0, width: 2, height: 2),
      );
      final b = makeNote(
        'b',
        const BoundingBox(x: 1, y: 1, width: 2, height: 2),
      );
      final pairs = detector.detect([a, b]);
      expect(pairs.length, 1);
    });

    test('two non-overlapping boxes → 0 pairs', () {
      final a = makeNote(
        'a',
        const BoundingBox(x: 0, y: 0, width: 1, height: 1),
      );
      final b = makeNote(
        'b',
        const BoundingBox(x: 5, y: 5, width: 1, height: 1),
      );
      final pairs = detector.detect([a, b]);
      expect(pairs, isEmpty);
    });

    test('element with isManualOverride=true is skipped', () {
      final a = makeNote(
        'a',
        const BoundingBox(x: 0, y: 0, width: 2, height: 2),
        manual: true,
      );
      final b = makeNote(
        'b',
        const BoundingBox(x: 1, y: 1, width: 2, height: 2),
        manual: true,
      );
      final pairs = detector.detect([a, b]);
      expect(pairs, isEmpty);
    });

    test('one manual one not → still detected', () {
      final a = makeNote(
        'a',
        const BoundingBox(x: 0, y: 0, width: 2, height: 2),
        manual: true,
      );
      final b = makeNote(
        'b',
        const BoundingBox(x: 1, y: 1, width: 2, height: 2),
      );
      final pairs = detector.detect([a, b]);
      expect(pairs.length, 1);
    });

    test('single element → no pairs', () {
      final a = makeNote(
        'a',
        const BoundingBox(x: 0, y: 0, width: 1, height: 1),
      );
      final pairs = detector.detect([a]);
      expect(pairs, isEmpty);
    });

    test('three overlapping elements → 3 pairs', () {
      final a = makeNote(
        'a',
        const BoundingBox(x: 0, y: 0, width: 3, height: 3),
      );
      final b = makeNote(
        'b',
        const BoundingBox(x: 1, y: 1, width: 3, height: 3),
      );
      final c = makeNote(
        'c',
        const BoundingBox(x: 2, y: 2, width: 3, height: 3),
      );
      final pairs = detector.detect([a, b, c]);
      expect(pairs.length, 3);
    });
  });
}
