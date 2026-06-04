import 'package:fast_immutable_collections/fast_immutable_collections.dart';

import '../ids.dart';
import 'beam_group.dart';
import 'slur.dart';
import 'staff.dart';
import 'tie.dart';
import 'tuplet.dart';

/// An instrument part containing one or more staves.
final class Part {
  const Part({
    required this.id,
    required this.name,
    this.shortName = '',
    this.staves = const IListConst([]),
    this.beamGroups = const IListConst([]),
    this.slurs = const IListConst([]),
    this.ties = const IListConst([]),
    this.tuplets = const IListConst([]),
  });

  final PartId id;
  final String name;
  final String shortName;
  final IList<Staff> staves;

  /// Beam groups referencing notes by ID within this part.
  final IList<BeamGroup> beamGroups;

  /// Slurs referencing notes by ID within this part.
  final IList<Slur> slurs;

  /// Ties referencing notes by ID within this part.
  final IList<Tie> ties;

  /// Tuplet groups referencing notes by ID within this part.
  final IList<Tuplet> tuplets;

  /// Returns the [Staff] with the given [id], or null if not found.
  Staff? findStaff(StaffId id) {
    final index = staves.indexWhere((s) => s.id == id);
    return index < 0 ? null : staves[index];
  }

  /// Returns a new [Part] with the staff identified by [id] transformed by
  /// [updater], or null if no staff with that ID exists or [updater] returns null.
  Part? updateStaff(StaffId id, Staff? Function(Staff) updater) {
    final index = staves.indexWhere((s) => s.id == id);
    if (index < 0) return null;
    final updated = updater(staves[index]);
    if (updated == null) return null;
    return copyWith(staves: staves.replace(index, updated));
  }

  Part copyWith({
    PartId? id,
    String? name,
    String? shortName,
    IList<Staff>? staves,
    IList<BeamGroup>? beamGroups,
    IList<Slur>? slurs,
    IList<Tie>? ties,
    IList<Tuplet>? tuplets,
  }) =>
      Part(
        id: id ?? this.id,
        name: name ?? this.name,
        shortName: shortName ?? this.shortName,
        staves: staves ?? this.staves,
        beamGroups: beamGroups ?? this.beamGroups,
        slurs: slurs ?? this.slurs,
        ties: ties ?? this.ties,
        tuplets: tuplets ?? this.tuplets,
      );
}
