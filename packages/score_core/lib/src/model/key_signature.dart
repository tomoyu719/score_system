/// Mode of a key signature.
enum Mode { major, minor }

/// Key signature expressed as sharps/flats count.
final class KeySignature {
  const KeySignature({required this.fifths, this.mode = Mode.major})
      : assert(fifths >= -7 && fifths <= 7, 'fifths must be -7 to +7');

  /// Number of sharps (positive) or flats (negative). 0 = C major / A minor.
  final int fifths;
  final Mode mode;

  KeySignature copyWith({int? fifths, Mode? mode}) => KeySignature(
        fifths: fifths ?? this.fifths,
        mode: mode ?? this.mode,
      );

  @override
  bool operator ==(Object other) {
    if (other is! KeySignature) return false;
    return fifths == other.fifths && mode == other.mode;
  }

  @override
  int get hashCode => Object.hash(fifths, mode);
}
