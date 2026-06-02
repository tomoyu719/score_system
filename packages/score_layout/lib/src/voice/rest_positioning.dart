import 'package:score_core/score_core.dart';

/// Determines the default staff-line position for rest symbols.
final class RestPositioning {
  const RestPositioning();

  /// Returns the staff-line position for a rest of the given [noteType].
  ///
  /// Whole and half rests sit above the middle line (staffLine 6).
  /// Quarter and shorter rests sit on the middle line (staffLine 4).
  double staffLineForRest(NoteType noteType) => switch (noteType) {
        NoteType.whole || NoteType.half => 6.0,
        _ => 4.0,
      };
}
