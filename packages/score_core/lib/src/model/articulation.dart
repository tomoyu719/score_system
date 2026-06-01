import 'placement.dart';

/// Articulation symbol types.
enum ArticulationType {
  accent,
  staccato,
  tenuto,
  fermata,
  marcato,
  staccatissimo,
  strongAccent,
  stress,
  unstress,
}

/// An articulation mark attached to a note or chord.
final class Articulation {
  const Articulation({required this.type, this.placement});

  final ArticulationType type;
  final Placement? placement;

  Articulation copyWith({ArticulationType? type, Placement? placement}) =>
      Articulation(
        type: type ?? this.type,
        placement: placement ?? this.placement,
      );

  @override
  bool operator ==(Object other) {
    if (other is! Articulation) return false;
    return type == other.type && placement == other.placement;
  }

  @override
  int get hashCode => Object.hash(type, placement);
}
