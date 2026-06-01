import 'package:fast_immutable_collections/fast_immutable_collections.dart';

import '../ids.dart';
import 'staff.dart';

/// An instrument part containing one or more staves.
final class Part {
  const Part({
    required this.id,
    required this.name,
    this.shortName = '',
    this.staves = const IListConst([]),
  });

  final PartId id;
  final String name;
  final String shortName;
  final IList<Staff> staves;

  Part copyWith({
    PartId? id,
    String? name,
    String? shortName,
    IList<Staff>? staves,
  }) =>
      Part(
        id: id ?? this.id,
        name: name ?? this.name,
        shortName: shortName ?? this.shortName,
        staves: staves ?? this.staves,
      );
}
