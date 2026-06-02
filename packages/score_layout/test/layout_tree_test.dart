import 'package:fast_immutable_collections/fast_immutable_collections.dart';
import 'package:score_layout/score_layout.dart';
import 'package:test/test.dart';

void main() {
  const bounds = BoundingBox(x: 0.0, y: 0.0, width: 20.0, height: 4.0);

  NoteheadElement makeNote(String id) => NoteheadElement(
        id: id,
        bounds: const BoundingBox(x: 0, y: 0, width: 1, height: 1),
        noteId: id,
        midiPitch: 60,
        staffLine: 0,
      );

  group('LayoutMeasure', () {
    test('copyWith replaces fields', () {
      final m = LayoutMeasure(
        measureNumber: 1,
        elements: IList(const []),
        bounds: bounds,
      );
      final m2 = m.copyWith(measureNumber: 2);
      expect(m2.measureNumber, 2);
      expect(m2.bounds, bounds);
    });
  });

  group('LayoutTree.findMeasure', () {
    test('returns correct measure when found', () {
      final measure = LayoutMeasure(
        measureNumber: 1,
        elements: IList([makeNote('n1')]),
        bounds: bounds,
      );
      final staff = LayoutStaff(
        staffId: 'staff-1',
        measures: IList([measure]),
        bounds: bounds,
      );
      final part = LayoutPart(
        partId: 'part-1',
        staves: IList([staff]),
        bounds: bounds,
      );
      final tree = LayoutTree(parts: IList([part]), bounds: bounds);

      final found = tree.findMeasure('part-1', 'staff-1', 1);
      expect(found, isNotNull);
      expect(found!.measureNumber, 1);
    });

    test('returns null when partId not found', () {
      final tree = LayoutTree(parts: IList(const []), bounds: bounds);
      expect(tree.findMeasure('nonexistent', 'staff-1', 1), isNull);
    });

    test('returns null when measure number not found', () {
      final measure = LayoutMeasure(
        measureNumber: 1,
        elements: IList(const []),
        bounds: bounds,
      );
      final staff = LayoutStaff(
        staffId: 'staff-1',
        measures: IList([measure]),
        bounds: bounds,
      );
      final part = LayoutPart(
        partId: 'part-1',
        staves: IList([staff]),
        bounds: bounds,
      );
      final tree = LayoutTree(parts: IList([part]), bounds: bounds);
      expect(tree.findMeasure('part-1', 'staff-1', 99), isNull);
    });
  });

  group('LayoutTree.allElements', () {
    test('iterates all elements across parts/staves/measures', () {
      final n1 = makeNote('n1');
      final n2 = makeNote('n2');
      final measure1 = LayoutMeasure(
        measureNumber: 1,
        elements: IList([n1]),
        bounds: bounds,
      );
      final measure2 = LayoutMeasure(
        measureNumber: 2,
        elements: IList([n2]),
        bounds: bounds,
      );
      final staff = LayoutStaff(
        staffId: 'staff-1',
        measures: IList([measure1, measure2]),
        bounds: bounds,
      );
      final part = LayoutPart(
        partId: 'part-1',
        staves: IList([staff]),
        bounds: bounds,
      );
      final tree = LayoutTree(parts: IList([part]), bounds: bounds);

      final elements = tree.allElements().toList();
      expect(elements.length, 2);
      expect(elements.map((e) => e.id), containsAll(['n1', 'n2']));
    });
  });

  group('LayoutTree.toJson', () {
    test('produces map with expected top-level keys', () {
      final tree = LayoutTree(parts: IList(const []), bounds: bounds);
      final json = tree.toJson();
      expect(json.containsKey('parts'), isTrue);
      expect(json.containsKey('bounds'), isTrue);
    });
  });
}
