import 'package:fast_immutable_collections/fast_immutable_collections.dart';

import '../ids.dart';
import 'measure.dart';

/// Staff type determines how the staff is rendered and edited.
enum StaffType { standard, tab, percussion }

/// A single staff (line group) within a Part.
///
/// Measures are keyed by 1-based measure number.
final class Staff {
  const Staff({
    required this.id,
    this.staffType = StaffType.standard,
    this.measures = const IMapConst({}),
  });

  final StaffId id;
  final StaffType staffType;

  /// Measures keyed by 1-based measure number.
  final IMap<int, Measure> measures;

  /// Returns a new [Staff] with the measure at [measureNumber] transformed by
  /// [updater]. Creates an empty [Measure] if that number does not yet exist.
  Staff updateMeasure(int measureNumber, Measure Function(Measure) updater) {
    final existing = measures[measureNumber] ?? Measure(id: IdFactory.measure());
    return copyWith(measures: measures.add(measureNumber, updater(existing)));
  }

  Staff copyWith({
    StaffId? id,
    StaffType? staffType,
    IMap<int, Measure>? measures,
  }) =>
      Staff(
        id: id ?? this.id,
        staffType: staffType ?? this.staffType,
        measures: measures ?? this.measures,
      );
}
