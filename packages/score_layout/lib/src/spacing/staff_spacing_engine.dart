import 'staff_extents.dart';

/// Computes vertical positions for staves on the page.
final class StaffSpacingEngine {
  const StaffSpacingEngine({
    this.staffHeight = 4.0,
    this.staffMargin = 2.0,
  });

  /// Vertical distance from the bottom staff line to the top staff line, in sp.
  final double staffHeight;

  /// Minimum vertical gap between adjacent staves, in sp.
  final double staffMargin;

  /// Returns the provisional Y position of the [staffIndex]-th staff (0-based),
  /// assuming uniform spacing with no content overflow.
  double yForStaff(int staffIndex) => staffIndex * (staffHeight + staffMargin);

  /// Returns content-aware Y positions for staves given their measured [extents].
  ///
  /// The gap between staff i and staff i+1 is:
  ///   staffHeight + extents[i].belowExtra + extents[i+1].aboveExtra + staffMargin
  ///
  /// Negative extra values are clamped to zero.
  List<double> yPositionsForExtents(List<StaffExtents> extents) {
    if (extents.isEmpty) return [];
    final positions = <double>[0.0];
    for (var i = 0; i < extents.length - 1; i++) {
      final below = extents[i].belowExtra.clamp(0.0, double.infinity);
      final above = extents[i + 1].aboveExtra.clamp(0.0, double.infinity);
      positions.add(positions.last + staffHeight + below + above + staffMargin);
    }
    return positions;
  }
}
