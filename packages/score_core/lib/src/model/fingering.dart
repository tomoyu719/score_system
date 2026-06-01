/// A fingering annotation (classical notation; 0 = open, 1–5 = fingers).
final class Fingering {
  const Fingering({required this.value, this.isSubstitution = false})
      : assert(value >= 0 && value <= 5, 'fingering value must be 0–5');

  /// Finger number: 0 = open string, 1–5 = fingers.
  final int value;

  /// Whether this is a substitution fingering (slurred change on same pitch).
  final bool isSubstitution;

  Fingering copyWith({int? value, bool? isSubstitution}) => Fingering(
        value: value ?? this.value,
        isSubstitution: isSubstitution ?? this.isSubstitution,
      );

  @override
  bool operator ==(Object other) {
    if (other is! Fingering) return false;
    return value == other.value && isSubstitution == other.isSubstitution;
  }

  @override
  int get hashCode => Object.hash(value, isSubstitution);
}
