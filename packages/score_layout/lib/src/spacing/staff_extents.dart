/// Vertical overflow of a staff's content beyond the staff lines, in sp.
final class StaffExtents {
  const StaffExtents({this.aboveExtra = 0.0, this.belowExtra = 0.0});

  /// Space elements extend above the top staff line.
  final double aboveExtra;

  /// Space elements extend below the bottom staff line.
  final double belowExtra;
}
