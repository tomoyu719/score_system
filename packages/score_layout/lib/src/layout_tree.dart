import 'package:fast_immutable_collections/fast_immutable_collections.dart';

import 'model/system_layout.dart';

/// Root of the logical layout output produced by [LayoutCalculator].
///
/// Contains one or more [SystemLayout] instances. MVP produces a single system.
/// All coordinates are logical (staff lines, proportional widths) — physical
/// sp/px values are assigned by the renderer layer.
final class LayoutTree {
  const LayoutTree({this.systems = const IListConst([])});

  final IList<SystemLayout> systems;

  Map<String, Object?> toJson() => {
        'systems': systems.map((s) => s.toJson()).toList(),
      };

  static LayoutTree fromJson(Map<String, Object?> map) => LayoutTree(
        systems: IList(
          (map['systems'] as List<dynamic>? ?? [])
              .map((e) => SystemLayout.fromJson(e as Map<String, Object?>)),
        ),
      );

  @override
  bool operator ==(Object other) {
    if (other is! LayoutTree) return false;
    return systems == other.systems;
  }

  @override
  int get hashCode => systems.hashCode;
}
