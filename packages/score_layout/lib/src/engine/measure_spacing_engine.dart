import 'package:score_core/score_core.dart';

/// Calculates the proportional width for each measure.
///
/// Width is proportional to the measure's time-signature duration. The
/// narrowest measure gets relativeWidth = 1.0; all others scale accordingly.
final class MeasureSpacingEngine {
  const MeasureSpacingEngine();

  /// Returns a list of (measureNumber, relativeWidth) records.
  ///
  /// When the score has no measure headers, returns an empty list.
  List<({int measureNumber, double relativeWidth})> calculate(Score score) {
    if (score.measureHeaders.isEmpty) return [];

    final rawWidths = [
      for (final h in score.measureHeaders)
        (measureNumber: h.measureNumber, raw: h.measureDuration.toDouble()),
    ];

    final minWidth =
        rawWidths.map((e) => e.raw).reduce((a, b) => a < b ? a : b);
    if (minWidth == 0) return [];

    return [
      for (final e in rawWidths)
        (measureNumber: e.measureNumber, relativeWidth: e.raw / minWidth),
    ];
  }
}
