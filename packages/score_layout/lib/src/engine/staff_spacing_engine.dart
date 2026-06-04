import 'package:score_core/score_core.dart';

import '../model/staff_layout.dart';

/// Assigns a logical vertical ordering index to each staff in the score.
///
/// MVP: staves are ordered top-to-bottom, iterating parts then staves within
/// each part. relativeY = 0 is the topmost staff.
final class StaffSpacingEngine {
  const StaffSpacingEngine();

  /// Returns [StaffLayout] entries for all staves across all parts.
  List<StaffLayout> calculate(Score score) {
    final result = <StaffLayout>[];
    var index = 0;
    for (final part in score.parts) {
      for (final staff in part.staves) {
        result.add(StaffLayout(
          partId: part.id,
          staffId: staff.id,
          relativeY: index++,
        ));
      }
    }
    return result;
  }
}
