import 'dart:math' as math;

import 'package:score_core/score_core.dart';

/// Computes measure widths and note x-positions using proportional (√duration) spacing.
///
/// Each note contributes `minNoteWidth + noteSpacing * sqrt(duration / quarter)` sp.
/// This compresses long notes relative to short ones, matching engraving convention.
final class MeasureSpacingEngine {
  const MeasureSpacingEngine({
    this.minNoteWidth = 1.5,
    this.noteSpacing = 4.0,
    this.minMeasureWidth = 20.0,
  });

  /// Minimum horizontal space per note in sp (approx. notehead width).
  final double minNoteWidth;

  /// Proportional spacing factor in sp per √quarter-note unit.
  final double noteSpacing;

  /// Minimum total measure width in sp.
  final double minMeasureWidth;

  static final _quarter = Fraction(1, 4);

  /// Total width (in sp) for [voice]. Always at least [minMeasureWidth].
  double measureWidth(Voice voice) {
    if (voice.events.isEmpty) return minMeasureWidth;
    var total = 0.0;
    for (final event in voice.events) {
      total += _noteWidth(event.duration);
    }
    return total < minMeasureWidth ? minMeasureWidth : total;
  }

  /// Maps every unique event onset offset to its x position (in sp) within the measure.
  ///
  /// Positions are computed from a shared grid built across all [voices], so
  /// events in different voices at the same offset always share the same x.
  Map<Fraction, double> xPositions(Iterable<Voice> voices) {
    // Collect all unique offsets across all voices.
    final offsets = <Fraction>{};
    for (final voice in voices) {
      for (final event in voice.events) {
        offsets.add(event.offset);
      }
    }
    if (offsets.isEmpty) return {};

    final sorted = offsets.toList()..sort();
    final result = <Fraction, double>{};
    var x = 0.0;
    result[sorted[0]] = x;
    for (var i = 1; i < sorted.length; i++) {
      final gap = sorted[i] - sorted[i - 1];
      x += _noteWidth(gap);
      result[sorted[i]] = x;
    }
    return result;
  }

  double _noteWidth(Fraction duration) {
    final ratio = (duration / _quarter).toDouble();
    return minNoteWidth + noteSpacing * math.sqrt(ratio);
  }
}
