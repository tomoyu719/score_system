import 'package:fast_immutable_collections/fast_immutable_collections.dart';

import 'measure_layout.dart';
import 'staff_layout.dart';

/// Layout data for one system (row of staves spanning multiple measures).
///
/// MVP: the [LayoutTree] contains exactly one system covering all measures.
final class SystemLayout {
  const SystemLayout({
    this.staves = const IListConst([]),
    this.measures = const IListConst([]),
  });

  final IList<StaffLayout> staves;
  final IList<MeasureLayout> measures;

  Map<String, Object?> toJson() => {
        'staves': staves.map((s) => s.toJson()).toList(),
        'measures': measures.map((m) => m.toJson()).toList(),
      };

  static SystemLayout fromJson(Map<String, Object?> map) => SystemLayout(
        staves: IList(
          (map['staves'] as List<dynamic>? ?? [])
              .map((e) => StaffLayout.fromJson(e as Map<String, Object?>)),
        ),
        measures: IList(
          (map['measures'] as List<dynamic>? ?? [])
              .map((e) => MeasureLayout.fromJson(e as Map<String, Object?>)),
        ),
      );

  @override
  bool operator ==(Object other) {
    if (other is! SystemLayout) return false;
    return staves == other.staves && measures == other.measures;
  }

  @override
  int get hashCode => Object.hash(staves, measures);
}
