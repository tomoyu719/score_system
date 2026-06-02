import 'package:score_layout/score_layout.dart';
import 'package:test/test.dart';

void main() {
  const manualOverride = ManualOverride();

  group('ManualOverride', () {
    test('apply sets isManualOverride to true', () {
      final el = NoteheadElement(
        id: 'n1',
        bounds: const BoundingBox(x: 0, y: 0, width: 1, height: 1),
        noteId: 'note-1',
        midiPitch: 60,
        staffLine: 0,
      );
      final newBounds = const BoundingBox(x: 5, y: 5, width: 1, height: 1);
      final result = manualOverride.apply(el, newBounds);
      expect(result.isManualOverride, isTrue);
    });

    test('apply sets new bounds', () {
      final el = NoteheadElement(
        id: 'n1',
        bounds: const BoundingBox(x: 0, y: 0, width: 1, height: 1),
        noteId: 'note-1',
        midiPitch: 60,
        staffLine: 0,
      );
      final newBounds = const BoundingBox(x: 5, y: 5, width: 2, height: 2);
      final result = manualOverride.apply(el, newBounds);
      expect(result.bounds, newBounds);
    });

    test('apply preserves subtype', () {
      final el = DynamicElement(
        id: 'd1',
        bounds: const BoundingBox(x: 0, y: 0, width: 1, height: 1),
        dynamicType: 'forte',
        placement: 'below',
      );
      final newBounds = const BoundingBox(x: 2, y: 2, width: 1, height: 1);
      final result = manualOverride.apply(el, newBounds);
      expect(result, isA<DynamicElement>());
      expect(result.isManualOverride, isTrue);
    });
  });
}
