import 'fraction.dart';

/// Time signature of a measure.
final class TimeSignature {
  const TimeSignature({required this.beats, required this.beatType});

  /// Number of beats per measure (numerator).
  final int beats;

  /// Note value that receives one beat (denominator).
  final int beatType;

  /// Duration of a full measure in whole-note units.
  Fraction get measureDuration => Fraction(beats, beatType);

  TimeSignature copyWith({int? beats, int? beatType}) => TimeSignature(
        beats: beats ?? this.beats,
        beatType: beatType ?? this.beatType,
      );

  @override
  bool operator ==(Object other) {
    if (other is! TimeSignature) return false;
    return beats == other.beats && beatType == other.beatType;
  }

  @override
  int get hashCode => Object.hash(beats, beatType);
}
