import 'package:fast_immutable_collections/fast_immutable_collections.dart';
import 'package:score_core/score_core.dart';

import 'layout_calculator.dart';
import 'layout_tree.dart';
import 'model/measure_layout.dart';

/// Cache of per-measure layout results to support incremental re-layout.
final class LayoutCache {
  const LayoutCache({this.cachedMeasures = const IMapConst({})});

  final IMap<int, MeasureLayout> cachedMeasures;

  /// Returns the [MeasureLayout] for [measureNumber], or null if not cached.
  MeasureLayout? get(int measureNumber) => cachedMeasures[measureNumber];

  /// Returns a new [LayoutCache] with [layout] stored at [measureNumber].
  LayoutCache put(int measureNumber, MeasureLayout layout) =>
      LayoutCache(cachedMeasures: cachedMeasures.add(measureNumber, layout));

  /// Returns a new [LayoutCache] with [measureNumbers] removed.
  LayoutCache invalidate(Set<int> measureNumbers) => LayoutCache(
        cachedMeasures: cachedMeasures.removeWhere(
          (k, _) => measureNumbers.contains(k),
        ),
      );

  /// Returns an empty [LayoutCache].
  LayoutCache clear() => const LayoutCache();
}

/// Calculates a [LayoutTree] for [score] and rebuilds [cache] from scratch.
///
/// MVP implementation: ignores the existing cache and recalculates everything.
/// A future optimisation can diff scoreBefore/scoreAfter to identify changed
/// measures and invalidate only those.
(LayoutTree, LayoutCache) calculateIncremental(Score score, LayoutCache cache) {
  final tree = LayoutCalculator().calculate(score);
  var newCache = cache.clear();
  if (tree.systems.isNotEmpty) {
    for (final measure in tree.systems.first.measures) {
      newCache = newCache.put(measure.measureNumber, measure);
    }
  }
  return (tree, newCache);
}
