import 'package:score_core/score_core.dart';

/// Computes the width of a measure based on its rhythmic content.
final class MeasureSpacingEngine {
  const MeasureSpacingEngine({
    this.minMeasureWidth = 20.0,
    this.noteSpacing = 4.0,
  });

  /// Minimum measure width in sp.
  final double minMeasureWidth;

  /// Sp of horizontal space per quarter-note duration.
  final double noteSpacing;

  /// Returns the width (in sp) needed to lay out [voice] within [measureDuration].
  ///
  /// Each event contributes `noteSpacing * (duration / quarter)` sp.
  /// The result is always at least [minMeasureWidth].
  double measureWidth(Voice voice, Fraction measureDuration) {
    final quarter = Fraction(1, 4);
    var total = 0.0;
    for (final event in voice.events) {
      final dur = event.duration;
      total += noteSpacing * (dur / quarter).toDouble();
    }
    return total < minMeasureWidth ? minMeasureWidth : total;
  }
}
