import 'package:score_layout/score_layout.dart';
import 'package:test/test.dart';

void main() {
  NoteheadElement makeNote(String id) => NoteheadElement(
        id: id,
        bounds: const BoundingBox(x: 0, y: 0, width: 1, height: 1),
        noteId: id,
        midiPitch: 60,
        staffLine: 0,
      );

  group('CollisionReport', () {
    test('hasCollisions is false when no pairs', () {
      final report = CollisionReport(
        pairs: const [],
        timestamp: DateTime(2026),
      );
      expect(report.hasCollisions, isFalse);
    });

    test('hasCollisions is true when pairs exist', () {
      final a = makeNote('a');
      final b = makeNote('b');
      final report = CollisionReport(
        pairs: [CollisionPair(a: a, b: b)],
        timestamp: DateTime(2026),
      );
      expect(report.hasCollisions, isTrue);
    });

    test('count returns number of pairs', () {
      final a = makeNote('a');
      final b = makeNote('b');
      final report = CollisionReport(
        pairs: [CollisionPair(a: a, b: b), CollisionPair(a: a, b: b)],
        timestamp: DateTime(2026),
      );
      expect(report.count, 2);
    });

    test('toJson contains expected keys', () {
      final report = CollisionReport(
        pairs: const [],
        timestamp: DateTime(2026),
      );
      final json = report.toJson();
      expect(json.containsKey('pairs'), isTrue);
      expect(json.containsKey('timestamp'), isTrue);
      expect(json.containsKey('count'), isTrue);
      expect(json.containsKey('hasCollisions'), isTrue);
    });
  });
}
