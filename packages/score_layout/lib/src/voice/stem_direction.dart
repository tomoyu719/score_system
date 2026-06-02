import '../layout_element.dart';

/// Determines stem direction based on a note's staff-line position.
final class StemDirectionPolicy {
  const StemDirectionPolicy();

  /// Notes on or above the middle staff line (staffLine >= 4) get stem down;
  /// notes below get stem up.
  StemDirection stemDirection(double staffLine) =>
      staffLine >= 4.0 ? StemDirection.down : StemDirection.up;
}
