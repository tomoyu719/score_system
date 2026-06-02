import 'package:score_layout/score_layout.dart';
import 'package:test/test.dart';

void main() {
  group('BoundingBox', () {
    test('right and bottom computed correctly', () {
      const box = BoundingBox(x: 1.0, y: 2.0, width: 3.0, height: 4.0);
      expect(box.right, 4.0);
      expect(box.bottom, 6.0);
    });

    test('overlaps returns true when boxes intersect', () {
      const a = BoundingBox(x: 0.0, y: 0.0, width: 2.0, height: 2.0);
      const b = BoundingBox(x: 1.0, y: 1.0, width: 2.0, height: 2.0);
      expect(a.overlaps(b), isTrue);
    });

    test('overlaps returns false when boxes do not intersect', () {
      const a = BoundingBox(x: 0.0, y: 0.0, width: 1.0, height: 1.0);
      const b = BoundingBox(x: 2.0, y: 2.0, width: 1.0, height: 1.0);
      expect(a.overlaps(b), isFalse);
    });

    test('overlaps returns false when boxes touch at edge', () {
      const a = BoundingBox(x: 0.0, y: 0.0, width: 1.0, height: 1.0);
      const b = BoundingBox(x: 1.0, y: 0.0, width: 1.0, height: 1.0);
      expect(a.overlaps(b), isFalse);
    });

    test('translate shifts x and y', () {
      const box = BoundingBox(x: 1.0, y: 2.0, width: 3.0, height: 4.0);
      final translated = box.translate(5.0, 6.0);
      expect(translated.x, 6.0);
      expect(translated.y, 8.0);
      expect(translated.width, 3.0);
      expect(translated.height, 4.0);
    });

    test('union returns smallest enclosing box', () {
      const a = BoundingBox(x: 0.0, y: 0.0, width: 2.0, height: 2.0);
      const b = BoundingBox(x: 1.0, y: 1.0, width: 3.0, height: 3.0);
      final u = a.union(b);
      expect(u.x, 0.0);
      expect(u.y, 0.0);
      expect(u.right, 4.0);
      expect(u.bottom, 4.0);
    });

    test('copyWith replaces specified fields', () {
      const box = BoundingBox(x: 1.0, y: 2.0, width: 3.0, height: 4.0);
      final copy = box.copyWith(x: 10.0, height: 20.0);
      expect(copy.x, 10.0);
      expect(copy.y, 2.0);
      expect(copy.width, 3.0);
      expect(copy.height, 20.0);
    });

    test('equality works', () {
      const a = BoundingBox(x: 1.0, y: 2.0, width: 3.0, height: 4.0);
      const b = BoundingBox(x: 1.0, y: 2.0, width: 3.0, height: 4.0);
      const c = BoundingBox(x: 0.0, y: 2.0, width: 3.0, height: 4.0);
      expect(a, equals(b));
      expect(a, isNot(equals(c)));
    });

    test('hashCode consistent with equality', () {
      const a = BoundingBox(x: 1.0, y: 2.0, width: 3.0, height: 4.0);
      const b = BoundingBox(x: 1.0, y: 2.0, width: 3.0, height: 4.0);
      expect(a.hashCode, equals(b.hashCode));
    });
  });
}
