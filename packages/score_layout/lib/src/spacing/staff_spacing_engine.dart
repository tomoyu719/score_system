/// Computes vertical positions for staves on the page.
final class StaffSpacingEngine {
  const StaffSpacingEngine({
    this.staffHeight = 4.0,
    this.staffMargin = 2.0,
  });

  /// Vertical distance from the bottom staff line to the top staff line, in sp.
  final double staffHeight;

  /// Vertical gap between adjacent staves, in sp.
  final double staffMargin;

  /// Returns the Y position (top edge) of the [staffIndex]-th staff (0-based).
  double yForStaff(int staffIndex) => staffIndex * (staffHeight + staffMargin);
}
