import '../layout_element.dart';
import 'collision_detector.dart';

/// Priority levels for collision resolution. Lower number = higher priority = immovable.
int _priority(LayoutElement el) => switch (el) {
      NoteheadElement() || BarlineElement() => 1,
      StemElement() => 2,
      AccidentalElement() => 3,
      ArticulationElement() => 4,
      DynamicElement() => 5,
      LyricElement() => 6,
      ClefElement() || TimeSignatureElement() || KeySignatureElement() => 1,
      RestElement() => 1,
    };

/// Resolves element collisions by nudging lower-priority elements away.
final class CollisionResolver {
  const CollisionResolver({
    this.maxIterations = 10,
    this.nudge = 0.5,
  });

  /// Maximum resolution passes before giving up.
  final int maxIterations;

  /// Distance (sp) to move an element per resolution step.
  final double nudge;

  /// Resolves collisions iteratively.
  ///
  /// Returns the updated elements list and any pairs that could not be resolved.
  ({List<LayoutElement> elements, List<CollisionPair> remaining}) resolve(
    List<LayoutElement> elements,
  ) {
    final current = List<LayoutElement>.from(elements);
    const detector = CollisionDetector();

    for (var iteration = 0; iteration < maxIterations; iteration++) {
      final pairs = detector.detect(current);
      if (pairs.isEmpty) break;

      var anyMoved = false;
      for (final pair in pairs) {
        final aIdx = current.indexWhere((e) => e.id == pair.a.id);
        final bIdx = current.indexWhere((e) => e.id == pair.b.id);
        if (aIdx < 0 || bIdx < 0) continue;

        final a = current[aIdx];
        final b = current[bIdx];

        final aPriority = _priority(a);
        final bPriority = _priority(b);

        // isManualOverride elements are never moved.
        final aMovable = !a.isManualOverride && aPriority > bPriority;
        final bMovable = !b.isManualOverride && bPriority > aPriority;

        // If neither can move (equal priority or both immovable), skip.
        if (!aMovable && !bMovable) continue;

        final target = aMovable ? a : b;
        final targetIdx = aMovable ? aIdx : bIdx;

        final moved = _nudgeAway(target, nudge, _priority(target));
        current[targetIdx] = moved;
        anyMoved = true;
      }

      if (!anyMoved) break;
    }

    final remaining = detector.detect(current);
    return (elements: current, remaining: remaining);
  }

  LayoutElement _nudgeAway(
    LayoutElement el,
    double amount,
    int priority,
  ) {
    // Movement axis depends on element type.
    switch (el) {
      case StemElement():
        // Stems: Y-extend only (grow height)
        return el.withBounds(
          el.bounds.copyWith(height: el.bounds.height + amount),
        );
      case AccidentalElement():
        // Accidentals: X only (move left)
        return el.withBounds(el.bounds.translate(-amount, 0));
      case ArticulationElement():
        // Articulations: Y only (move up)
        return el.withBounds(el.bounds.translate(0, -amount));
      case DynamicElement():
        // Dynamics: Y only (move down)
        return el.withBounds(el.bounds.translate(0, amount));
      case LyricElement():
        // Lyrics: Y down only
        return el.withBounds(el.bounds.translate(0, amount));
      case ClefElement() ||
            TimeSignatureElement() ||
            KeySignatureElement() ||
            NoteheadElement() ||
            BarlineElement() ||
            RestElement():
        // Immovable elements — return unchanged
        return el;
    }
  }
}
