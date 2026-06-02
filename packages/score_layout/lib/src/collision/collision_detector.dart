import '../layout_element.dart';

/// A pair of elements whose bounding boxes overlap.
final class CollisionPair {
  const CollisionPair({required this.a, required this.b});

  final LayoutElement a;
  final LayoutElement b;
}

/// Detects overlapping layout elements.
final class CollisionDetector {
  const CollisionDetector();

  /// Returns all overlapping element pairs.
  ///
  /// Pairs where BOTH elements have [LayoutElement.isManualOverride] true are
  /// excluded (both are intentionally placed; no automated resolution needed).
  List<CollisionPair> detect(List<LayoutElement> elements) {
    final pairs = <CollisionPair>[];
    for (var i = 0; i < elements.length; i++) {
      for (var j = i + 1; j < elements.length; j++) {
        final a = elements[i];
        final b = elements[j];
        if (a.isManualOverride && b.isManualOverride) continue;
        if (a.bounds.overlaps(b.bounds)) {
          pairs.add(CollisionPair(a: a, b: b));
        }
      }
    }
    return pairs;
  }
}
