import 'package:score_layout/score_layout.dart';
import 'package:test/test.dart';

void main() {
  const resolver = CollisionResolver();

  NoteheadElement makeNotehead(String id, BoundingBox bounds,
      {bool manual = false}) =>
      NoteheadElement(
        id: id,
        bounds: bounds,
        noteId: id,
        midiPitch: 60,
        staffLine: 0,
        isManualOverride: manual,
      );

  DynamicElement makeDynamic(String id, BoundingBox bounds,
      {bool manual = false}) =>
      DynamicElement(
        id: id,
        bounds: bounds,
        dynamicType: 'forte',
        placement: 'below',
        isManualOverride: manual,
      );

  group('CollisionResolver', () {
    test('low-priority element moved away from high-priority element', () {
      // Notehead (high priority) overlaps with DynamicElement (low priority)
      final notehead = makeNotehead(
        'note',
        const BoundingBox(x: 0, y: 0, width: 2, height: 2),
      );
      final dynamic_ = makeDynamic(
        'dyn',
        const BoundingBox(x: 0.5, y: 0.5, width: 2, height: 2),
      );

      final result = resolver.resolve([notehead, dynamic_]);
      // The dynamic should have moved, notehead stays
      final resolvedNotehead =
          result.elements.whereType<NoteheadElement>().first;
      final resolvedDynamic =
          result.elements.whereType<DynamicElement>().first;

      // Notehead should not have moved
      expect(resolvedNotehead.bounds, notehead.bounds);
      // Dynamic should have moved
      expect(resolvedDynamic.bounds, isNot(equals(dynamic_.bounds)));
    });

    test('isManualOverride=true element is not moved', () {
      final notehead = makeNotehead(
        'note',
        const BoundingBox(x: 0, y: 0, width: 2, height: 2),
      );
      final manualDynamic = makeDynamic(
        'dyn',
        const BoundingBox(x: 0.5, y: 0.5, width: 2, height: 2),
        manual: true,
      );

      final result = resolver.resolve([notehead, manualDynamic]);
      final resolvedDynamic =
          result.elements.whereType<DynamicElement>().first;
      // Manual override: should not be moved
      expect(resolvedDynamic.bounds, manualDynamic.bounds);
    });

    test('no collisions → remaining is empty', () {
      final a = makeNotehead(
        'a',
        const BoundingBox(x: 0, y: 0, width: 1, height: 1),
      );
      final b = makeNotehead(
        'b',
        const BoundingBox(x: 5, y: 5, width: 1, height: 1),
      );
      final result = resolver.resolve([a, b]);
      expect(result.remaining, isEmpty);
    });

    test('two noteheads (immovable) remain as unresolved', () {
      // Both noteheads are immovable — collision cannot be resolved
      final a = makeNotehead(
        'a',
        const BoundingBox(x: 0, y: 0, width: 2, height: 2),
      );
      final b = makeNotehead(
        'b',
        const BoundingBox(x: 1, y: 1, width: 2, height: 2),
      );
      final result = resolver.resolve([a, b]);
      expect(result.remaining, isNotEmpty);
    });
  });
}
