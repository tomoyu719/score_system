import 'placement.dart';

/// Dynamic marking types (pppp through ffff plus accent variants).
enum DynamicType { pppp, ppp, pp, p, mp, mf, f, ff, fff, ffff, fp, sf, sfz, fz, rf, rfz, sfp, sfpp }

/// A dynamic marking attached to a note or chord.
final class Dynamic {
  const Dynamic({required this.type, this.placement});

  final DynamicType type;
  final Placement? placement;

  Dynamic copyWith({DynamicType? type, Placement? placement}) => Dynamic(
        type: type ?? this.type,
        placement: placement ?? this.placement,
      );

  @override
  bool operator ==(Object other) {
    if (other is! Dynamic) return false;
    return type == other.type && placement == other.placement;
  }

  @override
  int get hashCode => Object.hash(type, placement);
}
